class DocTemplatesController < ApplicationController
  before_filter :authenticate_employee!
  before_filter :authenticate_admin!, :except => [:index]
  layout 'manage'

  def index
  	@doc_templates = DocTemplate.asc('attachments.name')
  end

  def new
  	@doc_template = DocTemplate.new
  	@doc_template.attachments.build
  end

  def edit
  	@doc_template = DocTemplate.find(params[:id])
  end

  def create
  	@doc_template = DocTemplate.new(params[:doc_template])

  	if @doc_template.save
  		flash[:notice] = "Doc Template Saved"
  		redirect_to doc_templates_path
  	else
  		render :action => "new"
  	end
  end

  def update
  	@doc_template = DocTemplate.find(params[:id])

  	if @doc_template.update_attributes(params[:doc_template])
  		flash[:notice] = "Doc Template Updated"
  		redirect_to doc_templates_path
  	else
  		render :action => "new"
  	end
  end

  def destroy
  	@doc_template = DocTemplate.find(params[:id])
  	@doc_template.destroy

    flash[:notice] = "Deleting Attachment"
    respond_to do |format|
      format.html { redirect_to @parent}
      format.js { render 'shared/destroy_success'}
    end

  end

end