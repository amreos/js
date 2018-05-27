#MailGun
# ActionMailer::Base.smtp_settings = {
#   :port           => ENV['MAILGUN_SMTP_PORT'],
#   :address        => ENV['MAILGUN_SMTP_SERVER'],
#   :user_name      => ENV['MAILGUN_SMTP_LOGIN'],
#   :password       => ENV['MAILGUN_SMTP_PASSWORD'],
#   :domain         => 'jsasearch.heroku.com',
#   :authentication => :plain
# }

#Sendgrid
ActionMailer::Base.smtp_settings = {
  :address        => 'smtp.sendgrid.net',
  :port           => '587',
  :authentication => :plain,
  :user_name      => ENV['SENDGRID_USERNAME'],
  :password       => ENV['SENDGRID_PASSWORD'],
  :domain         => 'heroku.com',
  :enable_starttls_auto => true
}