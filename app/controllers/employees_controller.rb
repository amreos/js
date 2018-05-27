class EmployeesController < ApplicationController
  before_filter :authenticate_employee!
  before_filter :authenticate_admin!, :only => [:new, :create, :destroy]

  helper_method :sort_column, :sort_direction
  layout 'manage'

  def index
    @employees = Employee.all.asc(:position)

    respond_to do |format|
      format.html # index.html.erb
      format.js
    end
  end

  def show
    @employee = Employee.find(params[:id])
    @open_jobs   = @employee.jobs.only(:id, :name, :facility_names, :facility_ids, :city_cache, :region_cache, :state, :client_id, :client_name, :updated_at).
                       open.
                       desc(:updated_at).limit(10).all
    @placed_jobs = @employee.jobs.only(:id, :name, :facility_names, :facility_ids, :city_cache, :region_cache, :state, :client_id, :client_name, :updated_at).
                      placed.
                      desc(:updated_at).limit(10).all
    @notes  = Note.where(:user_ids => @employee.id).desc(:updated_at).limit(5).all
  end

  def new
    @employee = Employee.new
    @employee.emails.build
    @employee.phones.build

  end

  def edit
    if admin?
      @employee = Employee.find(params[:id])
    else
      @employee = Employee.find(current_user.id)
    end

  end

  def create
    @employee = Employee.new(params[:employee])

    if @employee.save
      # Resque.enqueue(Activity, current_user.name, current_user.id, 0, 3, @employee.id, @employee.name)
      Activity.notify(current_user.name, current_user.id, 0, 3, @employee.id, @employee.name)
      redirect_to(@employee, :notice => 'Employee was successfully created.')
    else
      render :action => "new"
    end

  end

  def update
    if admin?
      @employee = Employee.find(params[:id])
      @employee.accessible = :all
    else
      @employee = Employee.find(current_user.id)
    end

    if @employee.update_attributes(params[:employee])
      redirect_to(@employee, :notice => 'Employee was successfully updated.')
    else
      render :action => "edit"
    end
  end

  def destroy
    @employee = Employee.find(params[:id])
    @employee.destroy
    # Resque.enqueue(Activity, current_user.name, current_user.id, 2, 3, @employee.id, @employee.name)
    Activity.notify(current_user.name, current_user.id, 2, 3, @employee.id, @employee.name)
    respond_to do |format|
      flash[:notice] = "Employee Destroyed"
      format.html { redirect_to(employees_url) }
      format.js { render 'shared/destroy_success' }
    end
  end

  def update_position
    if admin?
      params[:employee_position].each_with_index do |id, index|
        Employee.find(id).update_attribute(:position, index + 1)
      end
      respond_to do |format|
        format.js { render :nothing => true }
      end
    end
  end

  private

  def sort_column
    params[:sort]
  end

  def sort_direction
    params[:direction]
  end

end
