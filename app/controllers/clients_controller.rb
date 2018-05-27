class ClientsController < ApplicationController
  before_filter :authenticate_employee!
  before_filter :authenticate_admin!, :only => [:destroy, :edit_multiple, :update_multiple]

  helper_method :sort_column, :sort_direction
  layout 'manage'

  def index
    @clients = Client.advanced_search(params)

    respond_to do |format|
      format.html
      format.js
      format.csv { render :text => Client.export_csv_with_facilities(@clients) }
    end
  end

  def mass_email
    @recipients = Client.advanced_search(params.slice(*Client::ACCEPTABLE_QUERIES).update(:mass_email => 1))
    @counter_r  = @recipients.count
    @note       = Note.new(:author => current_user.name)

    respond_to do |format|
      format.html
    end
  end

  def show
    @client = Client.find(params[:id])
    @open_jobs   = @client.jobs.only(:id, :name, :facility_names, :facility_ids, :state, :region_cache, :city_cache, :client_id, :client_name, :updated_at).
                           where(:client_id => @client.id).not_placed.
                           desc(:updated_at).limit(10).all
    @placed_jobs = @client.jobs.only(:id, :name, :facility_names, :facility_ids, :state, :region_cache, :city_cache, :client_id, :client_name, :updated_at).
                           where(:client_id => @client.id).placed.
                           desc(:updated_at).limit(10).all
    @notes  = Note.where(:user_ids => @client.id).desc(:updated_at).limit(5).all
    @tasks  = Task.where(:completed => false).
                   where("$or" => [ { :goal_id => @client.id }, { :goal_parent_id => @client.id } ]).
                   asc(:due_at).limit(8).all

  end

  def new
    @client = Client.new() do |client|
      client.employee_id = current_user.id #overide attr_accesible
    end
    @client.phones.build
  end

  def edit
    @client = Client.find(params[:id])
  end

  # POST /clients
  def create
    @client = Client.new(params[:client]) do |client|
      client.employee_id = current_user.id #overide attr_accesible
    end

    if @client.save
      Activity.notify(current_user.name, current_user.id, 0, 2, @client.id, @client.name)
      redirect_to(@client, :notice => 'Client was successfully created.')
    else
      render :action => "new"
    end

  end

  # PUT /clients/1
  def update
    @client = Client.find(params[:id])
    @client.accessible = :all if admin?

    if @client.update_attributes(params[:client])
      Activity.notify(current_user.name, current_user.id, 1, 2, @client.id, @client.name)
      redirect_to(@client, :notice => 'Client was successfully updated.')
    else
      render :action => "edit"
    end

  end

  # DELETE /clients/1
  def destroy
    @client = Client.find(params[:id])
    Job.delete_all(:conditions => { :client_id => @client.id.to_s })
    @client.destroy
    Activity.notify(current_user.name, current_user.id, 2, 2, @client.id, @client.name)

    respond_to do |format|
      flash[:notice] = "Client and Associated Contacts, Facilities, and Jobs Destroyed"
      format.html { redirect_to(clients_url) }
      format.js { render 'shared/destroy_success' }
    end
  end

  # PUT /clients/1/update_status
  def update_status
    status = params[:new_status]
    @client = Client.find(params[:id])
    good_to_save = false

    if status.to_i != 5
      @client.state = status
      good_to_save = true
    elsif ( status.to_i == 5 ) && admin?
      @client.state = status
      good_to_save = true
    end

    respond_to do |format|
      if good_to_save && @client.update_attributes(:state => status)
        Activity.notify(current_user.name, current_user.id, 3, 2, @client.id, @client.name, @client.current_state)
        flash[:notice] = "Status Updated"
        format.js { render :partial => 'shared/update_status', :locals => { :f => @client } }
      else
        flash[:alert] = @client.errors.full_messages.first || "Not a correct status"
        format.js { render 'shared/error' }
      end
    end
  end

  # GET /clients/1/facility_check
  def check_facility
    @client = Client.find(params[:id])
    respond_to do |format|
      if @client.has_facilities
        format.js
      else
        flash[:alert] = "Client does not have any facilities"
        format.js { render 'shared/remove_facilities' }
      end
    end
  end

  def edit_multiple
    if params[:selected_clients].present?
      @clients = Client.find(params[:selected_clients])
    else
      flash[:alert] = "Select Clients to Edit Multiple at a Time"
      redirect_to clients_path
    end
  end

  def update_multiple
    @clients = Client.find(params[:selected_clients])
    @clients.each do |client|
      client.accessible = :all if admin?
      client.update_attributes(params[:client].reject { |k,v| v.blank? })
    end
    flash[:notice] = "Updated Clients"
    redirect_to clients_path
  end

  private

  def sort_column
    params[:sort]
  end

  def sort_direction
    params[:direction]
  end
end
