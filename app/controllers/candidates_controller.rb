class CandidatesController < ApplicationController
  before_filter :authenticate_employee!
  before_filter :authenticate_admin!, :only => [:destroy, :edit_multiple, :update_multiple, :mass_email]

  helper_method :sort_column, :sort_direction
  layout 'manage'

  def index
    @candidates = Candidate.advanced_search(params)

    respond_to do |format|
      format.html
      format.js
      format.csv { render :text => Candidate.export_csv(Candidate::CSV_EXPORT_ATTRIBUTES,
                                                        @candidates)}
    end
  end

  def mass_email
    @recipients = Candidate.advanced_search(params.slice(*Candidate::ACCEPTABLE_QUERIES).update(:mass_email => 1))
    @counter_r  = @recipients.count
    @note       = Note.new(:author => current_user.name)

    respond_to do |format|
      format.html
    end
  end

  def show
    @candidate = Candidate.find(params[:id])
    @notes  = Note.where(:user_ids => @candidate.id).desc(:updated_at).limit(5).all
    @tasks  = Task.where(:goal_id => @candidate.id, :completed => false).
                   asc(:due_at).limit(8).all
  end

  def new
    @candidate = Candidate.new()
    @candidate.employee_id = current_user.id #overide attr_accesible
    @candidate.emails.build
    @candidate.phones.build
  end

  def edit
    @candidate = Candidate.find(params[:id])
  end

  def create
    @candidate = Candidate.new(params[:candidate]) do |candidate|
      candidate.employee_id = current_user.id #overide attr_accesible
    end

    if @candidate.save
      Activity.notify(current_user.name, current_user.id, 0, 0, @candidate.id, @candidate.name)
      redirect_to(@candidate, :notice => 'Candidate was successfully created.')
    else
      render :action => "new"
    end

  end

  def update
    @candidate = Candidate.find(params[:id])
    @candidate.accessible = :all if admin?

    params[:candidate][:specialties]     ||= []
    params[:candidate][:education_types] ||= []
    params[:candidate][:interview_types] ||= []
    params[:candidate][:licenses]        ||= []

    if @candidate.update_attributes(params[:candidate])
      Activity.notify(current_user.name, current_user.id, 1, 0, @candidate.id, @candidate.name)
      redirect_to(@candidate, :notice => 'Candidate was successfully updated.')
    else
      render :action => "edit"
    end

  end

  def destroy
    @candidate = Candidate.find(params[:id])
    @candidate.destroy
    # Resque.enqueue(Activity, current_user.name, current_user.id, 2, 0, @candidate.id, @candidate.name)
    Activity.notify(current_user.name, current_user.id, 2, 0, @candidate.id, @candidate.name)

    respond_to do |format|
      flash[:notice] = "Candidate and Associated Work Histories Destroyed"
      format.html { redirect_to(candidates_url) }
      format.js { render 'shared/destroy_success' }
    end
  end

  def update_status
    status = params[:new_status]
    @candidate = Candidate.find(params[:id])
    good_to_save = false

    if status.to_i != 5
      @candidate.state = status
      good_to_save = true
    elsif ( status.to_i == 5 ) && admin?
      @candidate.state = status
      good_to_save = true
    end

    respond_to do |format|
      if good_to_save && @candidate.save
        Activity.notify(current_user.name, current_user.id, 3, 0, @candidate.id, @candidate.name, @candidate.current_state)
        flash[:notice] = "Status Updated"
        format.js { render :partial => 'shared/update_status', :locals => { :f => @candidate } }
      else
        flash[:alert] = @candidate.errors.full_messages.first || "Not a correct status"
        format.js { render 'shared/error' }
      end
    end
  end

  def edit_multiple
    if params[:selected_candidates].present?
      @candidates = Candidate.find(params[:selected_candidates])
    else
      flash[:alert] = "Select Candidates to Edit Multiple at a Time"
      redirect_to candidates_path
    end
  end

  def update_multiple
    @candidates = Candidate.find(params[:selected_candidates])
    @candidates.each do |candidate|
      candidate.accessible = :all if admin?
      candidate.update_attributes(params[:candidate].reject { |k,v| v.blank? })
    end
    flash[:notice] = "Updated Candidates"
    redirect_to candidates_path
  end

  private

  def sort_column
    params[:sort]
  end

  def sort_direction
    params[:direction]
  end

end
