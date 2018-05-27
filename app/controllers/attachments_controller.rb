class AttachmentsController < ApplicationController
  before_filter :authenticate_employee!
  layout 'manage'

  def show

   if DefaultVars::ALLOWED_ATTACHMENT_PARENT_TYPES.include? params[:file_parent_type]
     klass = params[:file_parent_type].constantize
     @parent = klass.find(params[:file_parent_id])

     @attachment = @parent.attachments.find(params[:id])

     respond_to do |format|
       flash[:notice] = 'Download Link Generated'
       format.js
     end

   else
     respond_to do |format|
       format.html { redirect_to manage_dashboard_path, :alert => "Cannot find Attachment" }
       format.js { render 'shared/error', :alert => 'Cannat find Attachment'}
     end

   end

  end

  def edit

   if DefaultVars::ALLOWED_ATTACHMENT_PARENT_TYPES.include? params[:file_parent_type]
     klass = params[:file_parent_type].constantize
     @parent = klass.find(params[:file_parent_id])

     @attachment = @parent.attachments.find(params[:id])

   else
     respond_to do |format|
       format.html { redirect_to manage_dashboard_path, :alert => "Cannot find Attachment" }
     end
   end

  end

  def create
    if DefaultVars::ALLOWED_ATTACHMENT_PARENT_TYPES.include? params[:file_parent_type]
      klass = params[:file_parent_type].constantize
      @parent = klass.find(params[:file_parent_id])

      @attachment = @parent.attachments.new(params[:attachment])

      if @attachment.save
        redirect_to @parent, :notice => "Attachment Saved"
      else
        redirect_to @parent, :alert => "Please Name your file and only use: .doc, .docx, .pdf, .pages"
      end
    else
      redirect_to manage_dashboard_path, :alert => "Cannot Add Attachments"
    end
  end

  def update
    if DefaultVars::ALLOWED_ATTACHMENT_PARENT_TYPES.include? params[:file_parent_type]
      klass = params[:file_parent_type].constantize
      @parent = klass.find(params[:file_parent_id])

      @attachment = @parent.attachments.find(params[:id])

      if @attachment.update_attributes(params[:attachment])
        redirect_to @parent, :notice => "Attachment Updated"
      else
        render :action => "edit", :alert => "Please Name your file and only use: .doc, .docx, .pdf, .pages"
      end
    else
      redirect_to manage_dashboard_path, :alert => "Cannot Add Attachments"
    end
  end

  def destroy
    if DefaultVars::ALLOWED_ATTACHMENT_PARENT_TYPES.include? params[:file_parent_type]
      klass = params[:file_parent_type].constantize
      @parent = klass.find(params[:file_parent_id])
      @attachment = @parent.attachments.find(params[:id])
      @attachment.destroy

      flash[:notice] = "Deleting Attachment"
      respond_to do |format|
        format.html { redirect_to @parent}
        format.js { render 'shared/destroy_success'}
      end
    else
      flash[:alert] = "Cannot Delete Attachment"
      respond_to do |format|
        format.html { redirect_to manage_dashboard_path}
        format.js { render 'shared/error'}
      end
    end
  end

end