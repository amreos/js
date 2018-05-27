class QuestionNotifications < ActionMailer::Base

  def notify_inquiry(question, employee, job)
    if employee.present?
      @send_to = employee.name.present? ? employee.name : "JSA Search"
      to_email = "info@jsasearch.net"
    else
      @send_to = "JSA Search"
      to_email = "info@jsasearch.net"
    end

    @job = job if job.present?
    
    @question = question
    email_with_name = %Q^"#{@question.inquirer}" <#{@question.inquirer_email}>^
    subject = @question.subject.present? ? @question.subject : "#{@question.inquirer} has asked a question about JSA Search"
    
    mail :to => to_email,
         :from => email_with_name,
         :subject => subject
  end
  
end