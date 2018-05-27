class MassMessagesController < ApplicationController
  before_filter :authenticate_admin!
  respond_to :js

  ALLOWED_PARENT_TYPES = %w(candidate client)

  def create
    options = params.dup
    if (ALLOWED_PARENT_TYPES.include? options[:recipient_type])
      @klass = options[:recipient_type].camelize.constantize
      search_string = params.slice(*@klass::ACCEPTABLE_QUERIES).update(:mass_email => 1)

      search_string[:licenses] = search_string[:licenses].split(",")       if search_string[:licenses].present?
      search_string[:specialties] = search_string[:specialties].split(",") if search_string[:specialties].present?
      search_string[:education] = search_string[:education].split(",")     if search_string[:education].present?

      @recipients = @klass.advanced_search(search_string)
      @note            = Note.new(options[:note])
      @note.emailed    = true
      @note.subject_required = true

      case @klass
        when Candidate then @note.user_tokens = current_user.id.to_s
        when Client then @note.user_tokens = current_user.id.to_s
      end

      if @note.save && @recipients.present?
        flash[:notice] = "Your Message Will Be Sent"
        Resque.enqueue(ResqueMassMessageNotification, @klass.name, search_string, @note.id, current_user.id)
      else
        flash[:alert] = @note.errors.full_messages.first || "Please enter a message"
        render 'shared/error'
      end

    else
      flash[:alert] = "Sorry, There Was an Error. Please try again"
      render 'shared/error'
    end
  end

end