require 'open-uri'
class EmployeeNotifications < ActionMailer::Base

  def notify_signup(person)
    @person        = person
    @employee      = @person.employee
    employee_email = "info@jsasearch.net"
    
    if @person.class == Client
      @url = client_url(@person)
    elsif @person.class == Candidate
      @url = candidate_url(@person)
    end    
    
    subject = "#{person.name} just signed up to be a #{person.class.name}"
    
    mail :to => employee_email,
         :from => '"JSA Search, Inc." <info@jsasearch.net>',
         :subject => subject
  end

  def notify_export(employee, export_file, klass)
    @employee = employee
    employee_email = @employee.email.present? ? @employee.email : "info@jsasearch.net"
    @klass = klass

    subject = "Here is your #{@klass.camelize} export"

    attachments["#{@klass.camelize.pluralize}.csv"] = {:content => export_file}

    mail :to => employee_email,
         :from => '"JSA Search, Inc." <info@jsasearch.net>',
         :subject => subject      
  end
  
  def notify_job_inquiry(job_inquiry, job, candidate = nil)
    employee_email = "info@jsasearch.net"
    @job_inquiry   = job_inquiry
    @job           = job
    @candidate     = candidate if candidate.present?

    subject = "#{@job_inquiry.name.split.first} inquired about job ##{@job.job_number}"    

    mail :to => employee_email,
         :from => '"JSA Search, Inc." <info@jsasearch.net>',
         :subject => subject      
  end

  def notify_job_request(job_request)    
    employee_email      = "info@jsasearch.net"
    @job_request  = job_request

    @user      = User.where('emails.address' => job_request.email_address).first
    @contact   = Contact.where('emails.address' => job_request.email_address).first
    @facility  = Facility.where('emails.address' => job_request.email_address).first

    if @job_request.attachments.present?
      attachment = @job_request.attachments.first
      open(attachment.misc_file.url, 'r', :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE) do |f|
        attachments["#{attachment[:misc_file]}"] = {:content => f.read,
                                                    :mime_type => attachment.content_type}
      end      
    end  

    subject = "#{@job_request.name.split.first} has submitted a Job Order Request" 

    mail :to => employee_email,
         :from => '"JSA Search, Inc." <info@jsasearch.net>',
         :subject => subject
    
  end  

  def notify_resume_submission(resume_submission, candidate = nil)    
    employee_email      = "info@jsasearch.net"
    @resume_submission  = resume_submission    
    @candidate          = candidate if candidate.present?

    if @resume_submission.attachments.present?
      attachment = @resume_submission.attachments.first
      open(attachment.misc_file.url, 'r', :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE) do |f|
        attachments["#{attachment[:misc_file]}"] = {:content => f.read,
                                                    :mime_type => attachment.content_type}
      end      
    end  

    subject = "#{@resume_submission.name.split.first} has submitted a resume" 

    mail :to => employee_email,
         :from => '"JSA Search, Inc." <info@jsasearch.net>',
         :subject => subject
    
  end  

end