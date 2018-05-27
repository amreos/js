class AdminDefaultsController < ApplicationController
  before_filter :authenticate_admin!
  layout 'manage'

  def index
  	@admin_default = AdminDefault.settings
  end

  def edit
  	@admin_default = AdminDefault.find(params[:id])
  end

  def update
  	@admin_default = AdminDefault.find(params[:id])

  	if @admin_default.update_attributes(params[:admin_default])
  		redirect_to admin_defaults_path
  	else
  		render 'edit'
  	end
  end

end