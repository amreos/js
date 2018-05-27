class MessageNotifications < ActionMailer::Base
  layout 'email_template'

  def notify_message(to_name, to_email, note, employee)
    @employee = employee
    @from_email          = @employee.emails.present? ? @employee.emails.first.address : "info@jsasearch.net"
    to_email_with_name   = %Q^"#{to_name}" <#{to_email}>^
    from_email_with_name = %Q^"#{@employee.name}" <#{@from_email}>^
    @bcc_emails = []

    @note = note

    if @note.subject.present?
      subject = @note.subject
    else
      subject = "A Note from #{@employee.name} and JSA Search"
    end

    if @note.email_attachments.present? &&
        @note.email_attachments.first.attachments.present?
      attachment = @note.email_attachments.first.attachments.first
      open(attachment.misc_file.url, 'r', :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE) do |f|
        attachments["#{attachment[:misc_file]}"] = {:content => f.read,
                                                    :mime_type => attachment.content_type}
      end
    end

    #set up bcc emails
    @bcc_emails << @note.bcc_email if @note.bcc_email.present?
    @bcc_emails << @from_email

    mail :to => to_email_with_name,
         :from => from_email_with_name,
         :bcc => @bcc_emails,
         :subject => subject
  end

  def notify_direct_message(note, employee)
    @employee = employee
    @note     = note
    @from_email = @employee.emails.present? ? @employee.emails.first.address : "info@jsasearch.net"
    @to_emails  = []
    @bcc_emails = []
    contacts = users = []

    #set up recipients
    @to_emails << @note.generic_emails if @note.email.present?

    @users = User.where(:_id.in => @note.user_ids).only(:id, :name, :emails, :email)
    @contacts = Contact.where(:_id.in => @note.contact_ids).only(:id, :name, :emails, :email)

    contacts = @contacts.map { |c| %Q^"#{c.name}" <#{c.emails.first.address}>^ }

    users = @users.map do |u|
      if u.class == Client
        %Q^"#{u.name}" <#{u.primary_contact_email}>^
      else
        %Q^"#{u.name}" <#{u.primary_email}>^
      end
    end

    @to_emails << contacts if contacts.present?

    @to_emails << users if users.present?

    #Set up From Email
    from_email_with_name = %Q^"#{@employee.name}" <#{@from_email}>^

    #set Up subject
    if @note.subject.present?
      subject = @note.subject
    else
      subject = "A Note from #{@employee.name} and JSA Search"
    end

    #set up attachments
    if @note.email_attachments.present? &&
        @note.email_attachments.first.attachments.present?
      attachment = @note.email_attachments.first.attachments.first
      open(attachment.misc_file.url, 'r', :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE) do |f|
        attachments["#{attachment[:misc_file]}"] = {:content => f.read,
                                                    :mime_type => attachment.content_type}
      end
    end

    #set up bcc emails
    @bcc_emails << @note.bcc_email if @note.bcc_email.present?
    @bcc_emails << @from_email

    mail :to => @to_emails,
         :bcc => @bcc_emails,
         :from => from_email_with_name,
         :subject => subject

  end

  def notify_mass_message(person, note, employee)
    @employee = employee
    @note     = note
    @recipient = person

    case @recipient.class
    when Candidate then @recipient_email = @recipient.emails.first.address
    when Client then @recipient_email = @recipient.primary_contact_email
    end

    @from_email     = @employee.emails.present? ? @employee.emails.first.address : "info@jsasearch.net"
    from_email_with_name = %Q^"#{@employee.name}" <#{@from_email}>^

    if @note.subject.present?
      subject = @note.subject
    else
      subject = "A Note from #{@employee.name} and JSA Search"
    end

    if @note.email_attachments.present? &&
        @note.email_attachments.first.attachments.present?
      attachment = @note.email_attachments.first.attachments.first
      open(attachment.misc_file.url, 'r', :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE) do |f|
        attachments["#{attachment[:misc_file]}"] = {:content => f.read,
                                                    :mime_type => attachment.content_type}
      end
    end

    mail :to => @recipient_email,
         :from => from_email_with_name,
         :subject => subject
  end

  def notify_file(shared_file, note, employee)
    @employee = employee
    @from_email          = @employee.emails.present? ? @employee.emails.first.address : "info@jsasearch.net"
    from_email_with_name = %Q^"#{@employee.name}" <#{@from_email}>^
    @note        = note
    @shared_file = shared_file
    @bcc_emails = []

    if @shared_file.present?
      open(@shared_file.misc_file.url,
           'r',
           :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE) do |f|
        attachments["#{@shared_file[:misc_file]}"] = {:content => f.read,
                                                      :mime_type => @shared_file.content_type}
      end
    end

    @users    = User.where(:_id.in => @note.user_ids).only(:id, :name, :emails, :email)
    @contacts = Contact.where(:_id.in => @note.contact_ids).only(:id, :name, :emails)

    recipients = contacts = users = []

    contacts = @contacts.map { |c| %Q^"#{c.name}" <#{c.emails.first.address}>^ }

    users = @users.map do |u|
      if u.class == Client
        %Q^"#{u.name}" <#{u.primary_contact_email}>^
      else
        %Q^"#{u.name}" <#{u.primary_email}>^
      end
    end

    recipients << @note.generic_emails if @note.email.present?
    recipients << contacts
    recipients << users

    #set up bcc emails
    @bcc_emails << @note.bcc_email if @note.bcc_email.present?
    @bcc_emails << @from_email

    if @note.subject.present?
      subject = @note.subject
    else
      subject = "A Note from #{@employee.name} and JSA Search"
    end

    mail :to => recipients,
         :from => from_email_with_name,
         :bcc => @bcc_emails,
         :subject => subject
  end

  def notify_resume(parent, shared_file, note, employee)
    @employee = employee
    @from_email          = @employee.emails.present? ? @employee.emails.first.address : "info@jsasearch.net"
    from_email_with_name = %Q^"#{@employee.name}" <#{@from_email}>^
    @note        = note
    @parent      = parent
    @shared_file = shared_file
    @bcc_emails = []

    @users    = User.where(:_id.in => @note.user_ids).only(:id, :name, :emails, :email)
    @contacts = Contact.where(:_id.in => @note.contact_ids).only(:id, :name, :emails)

    recipients = contacts = users = []

    contacts = @contacts.map { |c| %Q^"#{c.name}" <#{c.emails.first.address}>^ }

    users = @users.map do |u|
      if u.class == Client
        %Q^"#{u.name}" <#{u.primary_contact_email}>^
      else
        %Q^"#{u.name}" <#{u.primary_email}>^
      end
    end

    recipients << @note.generic_emails if @note.email.present?
    recipients << contacts
    recipients << users

    #set up bcc emails
    @bcc_emails << @note.bcc_email if @note.bcc_email.present?
    @bcc_emails << @from_email

    if @note.subject.present?
      subject = @note.subject
    else
      subject = "A Note from #{@employee.name} and JSA Search"
    end

    attachments["#{@shared_file.name}.pdf"] = @shared_file.generated_pdf.to_s

    mail :to => recipients,
         :from => from_email_with_name,
         :bcc => @bcc_emails,
         :subject => subject
  end

end