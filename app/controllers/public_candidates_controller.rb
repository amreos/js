class PublicCandidatesController < ApplicationController
  layout 'application'
  
  def new
    employee = params[:employee].present? ? Employee.find(params[:employee]) : Employee.default_contact
    
    @candidate = Candidate.new_with_employee(employee).build_contact_info
  end
  
  def create
    employee = params[:employee].present? ? Employee.find(params[:employee]) : Employee.default_contact
    
    @candidate = Candidate.new_with_employee(employee, params[:candidate])
    @candidate.source = "JSA Website"

    if @candidate.save
      Resque.enqueue(ResqueSignUpNotifications, @candidate.id)
      # Resque.enqueue(Activity, current_user.name, current_user.id, 0, 0, @candidate.id, @candidate.name)
      redirect_to(candidate_thank_you_path, :notice => 'Thank You for Signing Up, a Recruiter with Talk with You Soon.')
    else
      render :action => "new"
    end
      
  end
      
  def thanks
  end
  
end