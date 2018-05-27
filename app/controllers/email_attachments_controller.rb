class EmailAttachmentsController < ApplicationController
  before_filter :authenticate_employee!

  respond_to :json

  def create
  	file = params["files"][0]

  	@email_attachment = EmailAttachment.create

  	@attachment = Attachment.new(
  		name: 			file.original_filename,
  		misc_file: 	file
  	)

  	if @email_attachment.attachments << @attachment
  		render :json => { :success => true,
  						 					:email_attachment => {:name => @attachment.name,
  						 																:id => @email_attachment.id } }
  	else
  		@message =  @email_attachment.errors.full_messages.to_sentence
  		render :json => { :sucess => false, :error => { :message => @message } }
  	end

  end

  def destroy
    @email_attachment = EmailAttachment.where(:_id => params[:id]).first

    if @email_attachment.destroy
      render :json => { :success => true,
                        :email_attachment => { :id => @email_attachment.id } }
    end

  end

end