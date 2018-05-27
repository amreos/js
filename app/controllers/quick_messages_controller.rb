class QuickMessagesController < ApplicationController
  before_filter :authenticate_employee!
  respond_to :js

  ALLOWED_PARENT_TYPES = %w(candidate client employee job facility contact)

  def new
    options = params.dup
    if (ALLOWED_PARENT_TYPES.include? options[:recipient_type])
      recipient_type   = options[:recipient_type].camelize.constantize
      @recipient       = recipient_type.find(options[:recipient])
      @recipient_email = @recipient.emails.find(options[:recipient_email])

      @note = Note.new(:author => current_user.name)

    else
      flash[:alert] = "Sorry, There Was an Error. Please try again"
      render 'shared/error'
    end
  end

  def create
    options = params.dup
    if (ALLOWED_PARENT_TYPES.include? options[:recipient_type])
      recipient_type   = options[:recipient_type].camelize.constantize
      @recipient       = recipient_type.find(options[:recipient])
      @recipient_email = @recipient.emails.find(options[:recipient_email])
      @note            = Note.new(options[:note])
      @note.emailed    = true
      @note.subject_required = true

      case recipient_type
        when Candidate then @note.user_tokens = @recipient.id.to_s
        when Client    then @note.user_tokens = @recipient.id.to_s
        when Employee  then @note.user_tokens = @recipient.id.to_s
        when Contact   then @note.contact_tokens = @recipient.id.to_s
        when Facility  then @note.user_tokens    = @recipient.client.id.to_s
      end

      if @note.save && @recipient_email.present?
        flash[:notice] = "Your Message Has Been Sent"
        Resque.enqueue(ResqueQuickMessageNotification, @recipient.name, @recipient_email.address, @recipient.class.to_s, @note.id, current_user.id)
        render 'notes/create'
      else
        flash[:alert] = @note.errors.full_messages.first || "Please enter a message"
        render :partial => 'questions/error'
      end

    else
      flash[:alert] = "Sorry, There Was an Error. Please try again"
      render 'shared/error'
    end
  end

end