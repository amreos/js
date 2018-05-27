class ShareFilesController < ApplicationController
  before_filter :authenticate_employee!
  respond_to :js

  ALLOWED_PARENT_TYPES = %w(Candidate Client Employee Job Contact)
  ALLOWED_FILE_TYPES = %w(Resume Attachment)

  def new
    options = params.dup
    if (ALLOWED_PARENT_TYPES.include? options[:parent_type]) && (ALLOWED_FILE_TYPES.include? options[:shared_file_type])
      @note = Note.new(:author => current_user.name)

    else
      flash[:alert] = "Sorry, There Was an Error. Please try again"
      render 'shared/error'
    end
  end

  def create
    options = params.dup
    if (ALLOWED_PARENT_TYPES.include? options[:parent_type]) &&
       (ALLOWED_FILE_TYPES.include? options[:shared_file_type])

      @note = Note.new(options[:note])
      @note.emailed = true
      @note.subject_required = true

      parent_type   = options[:parent_type].camelize.constantize
      file_type     = options[:shared_file_type].downcase.pluralize

      @parent       = parent_type.find(options[:parent_id])
      @shared_file  = @parent.send(file_type).find(options[:shared_file_id])

      if @note.save && @shared_file.present?
        flash[:notice] = "File has Been Shared"
        Resque.enqueue(ResqueShareFileNotification, @parent.class.to_s, @parent.id, @shared_file.class.to_s, @shared_file.id, @note.id, current_user.id)
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