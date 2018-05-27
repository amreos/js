class FacilitiesController < ApplicationController
  before_filter :authenticate_employee!
  before_filter :authenticate_admin!, :only => [:destroy, :list, :mass_update]
  before_filter :load_client, :except => [:list, :mass_update]
  layout 'manage'

  helper_method :sort_column, :sort_direction

  def index

    if params[:name]
      term = escape_term(params[:name])
      facilities = @client.facilities.only(:name, :id).limit(10).where(:name => /#{term}*/i).asc(:name)
      results = facilities.map { |f| { :label => f.name, :value => f.name, :id => f.id } }
    end

    respond_to do |format|
      format.html { redirect_to client }
      format.js { render :json => results }
    end

  end

  def list
    @facilities = Facility.advanced_search(params)

    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    @facility = @client.facilities.find(params[:id])
    @contacts = Contact.where(:facility_ids => @facility.id ).all

    respond_to do |format|
      unless @facility.blank?
        format.js
      else
        flash[:alert] = "Not Found. Please try again."
        format.js { render 'shared/error' }
      end
    end
  end

  def new
    @facility = @client.facilities.build()
    @facility.addresses.build
    @facility.phones.build
  end

  def edit
    @facility = @client.facilities.find(params[:id])
  end

  # POST /clients/1/facilitys
  def create
    @facility = @client.facilities.create(params[:facility])

    if @facility.save
      # Resque.enqueue(Activity, current_user.name, current_user.id, 0, 4, @client.id, @facility.name)
      Activity.notify(current_user.name, current_user.id, 0, 4, @client.id, @facility.name)
      redirect_to(@client, :notice => 'Facility was successfully created.')
    else
      render :action => "new"
    end

  end

  # PUT /clients/1/facility/1
  def update
    @facility = @client.facilities.find(params[:id])

    if @facility.update_attributes(params[:facility])
      # Resque.enqueue(Activity, current_user.name, current_user.id, 1, 4, @client.id, @facility.name)
      Activity.notify(current_user.name, current_user.id, 1, 4, @client.id, @facility.name)
      redirect_to(@client, :notice => 'Facility was successfully updated.')
    else
      render :action => "edit"
    end

  end

  # DELETE /clients/1/facility/1
  def destroy
    @facility = @client.facilities.find(params[:id])
    @facility.destroy
    # Resque.enqueue(Activity, current_user.name, current_user.id, 2, 4, @client.id, @facility.name)
    Activity.notify(current_user.name, current_user.id, 2, 4, @client.id, @facility.name)
    respond_to do |format|
      format.html { redirect_to(@client, :notice => 'Facility was successfully Deleted.') }
      format.js { render 'shared/destroy_success', :notice => 'Facility was successfully Deleted.' }
    end
  end

  def tokens
    term = params[:name]
    facilities = @client.facilities.only(:name, :id).limit(10).where(:name => /#{escape_term(term)}*/i).asc(:name)
    results = facilities.map { |f| { :name => f.name, :id => f.id } }

    respond_to do |format|
      format.html { render :json => results } # debugging to browser... delete this
      format.json { render :json => results}
    end

  end

  def mass_update
    @facilities = Facility.find(params[:selected_facilities]) if params[:selected_facilities].present?

    if params[:client_id].present? && @facilities.present?
      @facilities.each do |facility|
        client = Client.find(params[:client_id])
        if client.present?
          facility.client = client
          facility.save
        end
      end

      flash[:notice] = "Updated Facilites"
      redirect_to list_facilities_path

    else
      flash[:alert] = "Please Select Facilities and Search for a Client"
      redirect_to list_facilities_path
    end

  end

  private

  def load_client
    @client = Client.find(params[:client_id])
  end

  def sort_column
    params[:sort]
  end

  def sort_direction
    params[:direction]
  end

end
