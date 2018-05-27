module ResqueSignUpNotifications

  @queue = :sign_up_notifications

  def self.perform(user_id)
    begin
      person = User.find(user_id)

      if person.class == Client
        ClientNotifications.notify_signup(person).deliver
      elsif person.class == Candidate
        CandidateNotifications.notify_signup(person).deliver
      end

      EmployeeNotifications.notify_signup(person).deliver
    rescue
    end

  end
end

module ResqueMassMessageNotification

  @queue = :mass_message_notifications

  # Resque.enqueue(ResqueMassMessageNotification, @klass, @search_string, @note.id, current_user.id)
  def self.perform(search_klass, search_string, note_id, employee_id)
    begin
      klass = search_klass.camelize.constantize
      params = {}
      search_string.each do |k,v|
        params.update(k.to_sym => v)
      end

      @employee = Employee.find(employee_id)
      @note = Note.find(note_id)
      @recipients = klass.advanced_search(params)

      Activity.notify(@employee.name, @employee.id, 5, 6, @note.id, @note.recipients)

      @recipients.each do |r|
        if r.primary_contact_email.present?
          MessageNotifications.notify_mass_message(r, @note, @employee).deliver
        end
      end

    rescue
    end
  end
end


module ResqueDirectMessageNotification

  @queue = :direct_message_notifications

  # Resque.enqueue(ResqueDirectMessageNotification, @note.id, current_user.id)
  def self.perform(note_id, employee_id)
    begin
      @employee = Employee.find(employee_id)
      @note = Note.find(note_id)
      Activity.notify(@employee.name, @employee.id, 5, 6, @note.id, @note.email)
      MessageNotifications.notify_direct_message(@note, @employee).deliver
    rescue
    end
  end
end


module ResqueQuickMessageNotification

  @queue = :quick_message_notifications

  # Resque.enqueue(ResqueQuickMessageNotification, @recipient.name, @recipient_email.address, to_class, @note.content, current_user.id)
  def self.perform(to_name, to_email, to_class, note_id, employee_id)
    begin
      @employee = Employee.find(employee_id)
      @note = Note.find(note_id)
      Activity.notify(@employee.name, @employee.id, 4, 6, @note.id, to_name, to_class)
      MessageNotifications.notify_message(to_name, to_email, @note, @employee).deliver
    rescue
    end
  end
end

module ResqueShareFileNotification

  @queue = :file_notifications

  # Resque.enqueue(ResqueShareFileNotification, @parent.class, @parent.id, @shared_file.class, @shared_file.id, @note.id, current_user.id, shared_file_url)
  def self.perform(parent_type, parent_id, shared_file_type, shared_file_id, note_id, employee_id)
    begin

      parent_type   = parent_type.camelize.constantize
      file_type     = shared_file_type.downcase.pluralize

      @parent       = parent_type.find(parent_id)
      @shared_file  = @parent.send(file_type).find(shared_file_id)

      @employee = Employee.find(employee_id)
      @note = Note.find(note_id)

      # Set quick note as record to sending file and save it to the person the file belongs to, ie, the canidate
      @parent_note          = Note.new()
      @parent_note.author   = @employee.name
      @parent_note.user_ids.push @parent._id
      @parent_note.content  = "Emailed #{shared_file_type} - #{@shared_file.name} to: #{@note.recipients}"
      @parent_note.save

      Activity.notify(@employee.name, @employee.id, 4, 6, @note.id, @parent.name, parent_type.to_s)

      if @shared_file.class == Attachment
        MessageNotifications.notify_file(@shared_file, @note, @employee).deliver
      elsif @shared_file.class == Resume
        MessageNotifications.notify_resume(@parent, @shared_file, @note, @employee).deliver
      end
    rescue
    end
  end
end

module ResqueExportNotification

  @queue = :export_notifications

  def self.perform(user_id, params)
    begin

      Employee.export_notification(user_id, params)

    rescue Exception => e
      Rails.logger.info "\n******** Export Failed: #{e.message}\n"
    rescue
      Rails.logger.info "\n******** Export Failed\n"
    ensure
      Rails.logger.info "\n******** Finished Export\n"
    end

  end
end

module ResqueJobInquiryNotification

  @queue = :job_inquiry_notifications

  def self.perform(job_inquiry_id)
    begin

      JobInquiry.send_inquiry_email(job_inquiry_id)

    rescue Exception => e
      Rails.logger.info "\n******** Email Failed: #{e.message}\n"
    rescue
      Rails.logger.info "\n******** Email Failed\n"
    ensure
      Rails.logger.info "\n******** Finished Email\n"
    end

  end
end

module ResqueJobRequestNotification

  @queue = :job_request_notifications

  def self.perform(job_request_id)
    begin

      JobRequest.send_request_email(job_request_id)

    rescue Exception => e
      Rails.logger.info "\n******** Email Failed: #{e.message}\n"
    rescue
      Rails.logger.info "\n******** Email Failed\n"
    ensure
      Rails.logger.info "\n******** Finished Email\n"
    end

  end
end

module ResqueResumeSubmissionNotification

  @queue = :resume_submissions_notifications

  def self.perform(resume_submission_id)
    begin

      ResumeSubmission.send_resume_submission_email(resume_submission_id)

    rescue Exception => e
      Rails.logger.info "\n******** Email Failed: #{e.message}\n"
    rescue
      Rails.logger.info "\n******** Email Failed\n"
    ensure
      Rails.logger.info "\n******** Finished Email\n"
    end

  end
end