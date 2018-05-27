class DirectMessagesController < ApplicationController
  before_filter :authenticate_employee!
  respond_to :js

  def new

    @note = Note.new(:author => current_user.name)

  end

  def create
    options = params.dup

    @note         = Note.new(options[:note])
    @note.emailed = true
    @note.emailed    = true
    @note.subject_required = true

    if @note.save
      flash[:notice] = "Your Message Has Been Sent"
      Resque.enqueue(ResqueDirectMessageNotification, @note.id, current_user.id)
      render 'notes/create'
    else
      flash[:alert] = @note.errors.full_messages.first || "Please enter a message"
      render :partial => 'questions/error'
    end

  end

end