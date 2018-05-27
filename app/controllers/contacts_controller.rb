class ContactsController < ApplicationController
  before_filter :authenticate_employee!
  before_filter :authenticate_admin!, :only => [:destroy, :list, :mass_update]
  before_filter :load_client, :except => [:list, :mass_update]
  layout 'manage'

  helper_method :sort_column, :sort_direction

  def index

    if params[:name]
      term = escape_term(params[:name])
      contacts = @client.contacts.only(:name, :id).limit(10).where(:name => /#{term}*/i).asc(:name)

      results = contacts.map { |f| { :label => f.name, :value => f.name, :id => f.id } }
    end

    respond_to do |format|
      format.html { redirect_to @client }
      format.js { render :json => results }
    end

  end

  def list
    @contacts = Contact.advanced_search(params)

    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    @contact    = @client.contacts.find(params[:id])
    @facilities = Facility.where(:_id.in => @contact.facility_ids).limit(10).desc(:udpated_at) unless @contact.facility_ids.blank?
    @notes      = Note.where(:contact_ids => @contact.id).desc(:updated_at).limit(5).all
    @tasks  = Task.where(:goal_id => @contact.id, :completed => false).
                   asc(:due_at).limit(8).all

    respond_to do |format|
      unless @contact.blank?
        format.js
        format.html
      else
        flash[:alert] = "Not Found. Please try again."
        format.js { render 'shared/error' }
        format.html
      end
    end
  end

  def new
    @contact = @client.contacts.build
    @contact.emails.build
    @contact.phones.build

    respond_to do |format|
      format.html
      format.js
    end
  end

  def edit
    @contact = @client.contacts.find(params[:id])
    @facilities = Facility.where(:_id.in => @contact.facility_ids).all
  end

  # POST /clients/1/contacts
  def create
    @contact = @client.contacts.create(params[:contact])

    respond_to do |format|
      if @contact.save
        Activity.notify(current_user.name, current_user.id, 0, 1, @client.id, @contact.name )
        format.html { redirect_to(@client, :notice => 'Contact was successfully created.') }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /clients/1/contact/1
  def update
    @contact = @client.contacts.find(params[:id])

    respond_to do |format|
      if @contact.update_attributes(params[:contact])
        Activity.notify(current_user.name, current_user.id, 1, 1, @client.id, @contact.name)
        format.html { redirect_to(@client, :notice => 'Contact was successfully updated.') }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /clients/1/contact/1
  def destroy
    @contact = @client.contacts.find(params[:id])
    @contact.destroy
    # Resque.enqueue(Activity, current_user.name, current_user.id, 2, 1, @client.id, @contact.name)
    Activity.notify(current_user.name, current_user.id, 2, 1, @client.id, @contact.name)

    respond_to do |format|
      format.html { redirect_to(@client, :notice => 'Contact was successfully Deleted.') }
      format.js { render 'shared/destroy_success', :notice => 'Contact was successfully Deleted.' }
    end
  end

 def mass_update
    @contacts = Contact.find(params[:selected_contacts]) if params[:selected_contacts].present?

    if params[:client_id].present? && @contacts.present?
      @contacts.each do |contact|
        client = Client.find(params[:client_id])
        if client.present?
          contact.client = client
          contact.save
        end
      end

      flash[:notice] = "Updated Contacts"
      redirect_to list_contacts_path

    else
      flash[:alert] = "Please Select Contacts and Search for a Client"
      redirect_to list_contacts_path
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
