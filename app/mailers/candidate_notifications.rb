class CandidateNotifications < ActionMailer::Base

  def notify_signup(candidate)
    @candidate = candidate
    subject = "Thanks for Signing up with JSA Search, Inc."
    
    mail :to => @candidate.emails.first.address,
         :from => '"JSA Search, Inc." <info@jsasearch.net>',
         :subject => subject
  end
  
end