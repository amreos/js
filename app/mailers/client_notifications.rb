class ClientNotifications < ActionMailer::Base

  def notify_signup(client)
    @client = client
    subject = "Thanks for Signing up with JSA Search, Inc."
    
    mail :to => @client.emails.first.address,
         :from => '"JSA Search, Inc." <info@jsasearch.net>',
         :subject => subject
  end
  
end