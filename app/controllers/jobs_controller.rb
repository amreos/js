class JobsController < ApplicationController
  before_filter :authenticate_employee!
  before_filter :authenticate_admin!, :only => [:destroy, :edit_multiple, :update_multiple]

  helper_method :sort_column, :sort_direction
  layout 'manage'

  def index
    @jobs = Job.advanced_search(params)

    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    @job      = Job.find(params[:id])
    @client   = Client.find(@job.client_id)
    @facility = Facility.find(@job.facility_ids.first) unless @job.facility_ids.blank?
    @notes    = Note.where(:job_ids => @job.id).desc(:updated_at).limit(5).all
    @tasks    = Task.where(:goal_id => @job.id, :completed => false).
                     asc(:due_at).limit(8).all
  end

  def new
    @job = Job.new()
    @job.accessible = :all if admin?
    @job.employee_id = current_user.id #overide attr_accesible

  end

  def edit
    @job = Job.find(params[:id])
    @client = Client.find(@job.client_id)
  end

  # POST /jobs
  def create
    @job = Job.new()
    @job.accessible = :all if admin?
    @job.attributes = params[:job]
    @job.employee_id = params[:job][:employee_id] #overide attr_accesible for employee_id on create

    if @job.save
      # Resque.enqueue(Activity, current_user.name, current_user.id, 0, 5, @job.id, @job.name)
      Activity.notify(current_user.name, current_user.id, 0, 5, @job.id, @job.name)
      redirect_to(@job, :notice => 'Job was successfully created.')
    else
      render :action => "new"
    end

  end

  # PUT /jobs/1
  def update
    @job = Job.find(params[:id])
    @job.accessible = :all if admin?

    params[:job][:mix_types]     ||= []
    params[:job][:special_units] ||= []
    params[:job][:benefits]      ||= []
    params[:job][:licenses]      ||= []

    if @job.update_attributes(params[:job])
      # Resque.enqueue(Activity, current_user.name, current_user.id, 1, 5, @job.id, @job.name)
      Activity.notify(current_user.name, current_user.id, 1, 5, @job.id, @job.name)
      redirect_to(@job, :notice => 'Job was successfully updated.')
    else
      render :action => "edit"
    end

  end

  def delete
    @job = Job.find(params[:id])
  end

  # DELETE /jobs/1
  def destroy
    @job = Job.find(params[:id])

    respond_to do |format|
      if @job.destroy
        Activity.notify(current_user.name, current_user.id, 2, 5, @job.id, @job.name)
        flash[:notice] = "Job Successfully Destroyed"
        format.html { redirect_to(jobs_url) }
        format.js { render 'shared/destroy_success' }
      end
    end
  end

  # PUT /jobs/1/update_status
  def update_status
    status = params[:new_status]
    @job = Job.find(params[:id])
    good_to_save = false

    if status.to_i != 5
      @job.state = status
      good_to_save = true
    elsif ( status.to_i == 5 ) && admin?
      @job.state = status
      good_to_save = true
    end

    respond_to do |format|
      if good_to_save && @job.update_attributes(:state => status)
        Activity.notify(current_user.name, current_user.id, 3, 5, @job.id, @job.name, @job.current_state)
        flash[:notice] = "Status Updated"
        format.js { render :partial => 'shared/update_status', :locals => { :f => @job } }
      else
        flash[:alert] = @job.errors.full_messages.first || "Not a correct status"
        format.js { render 'shared/error' }
      end
    end
  end

  def edit_multiple
    if params[:selected_jobs].present?
      @jobs = Job.find(params[:selected_jobs])
    else
      flash[:alert] = "Select Jobs to Edit Multiple at a Time"
      redirect_to jobs_path
    end
  end

  def update_multiple
    @jobs = Job.find(params[:selected_jobs])
    @jobs.each do |job|
      job.accessible = :all if admin?
      job.update_attributes(params[:job].reject { |k,v| v.blank? })
    end
    flash[:notice] = "Updated Jobs"
    redirect_to jobs_path
  end

  private

  def sort_column
    params[:sort]
  end

  def sort_direction
    params[:direction]
  end

end
