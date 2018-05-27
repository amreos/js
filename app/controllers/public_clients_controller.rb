class PublicClientsController < ApplicationController
  layout 'application'
    
  def new
    employee = params[:employee].present? ? Employee.find(params[:employee]) : Employee.default_contact

    @client = Client.new_with_employee(employee).build_contact_info
  end
  
  def create
    employee = params[:employee].present? ? Employee.find(params[:employee]) : Employee.default_contact
    
    @client = Client.new_with_employee(employee, params[:client])
    @client.source = "JSA Website"

    if @client.save
      Resque.enqueue(ResqueSignUpNotifications, @client.id)
      # Resque.enqueue(Activity, current_user.name, current_user.id, 0, 0, @client.id, @client.name)
      redirect_to(client_thank_you_path, :notice => 'Thank You for Signing Up, a Recruiter with Talk with You Soon.')
    else
      render :action => "new"
    end
      
  end
  
  def thanks
  end
      
end