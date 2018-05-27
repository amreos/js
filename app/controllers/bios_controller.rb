class BiosController < ApplicationController
  layout 'public'

  def index
    @employees = Employee.where(:display_bio => true).asc(:position)
  end

  def show
    @employee = Employee.where(:display_bio => true, :_id => params[:id]).first

    respond_to do |format|
      format.js { flash[:notice] = "Bio Loaded" if @employee.present? }
      format.html { redirect_to bios_path }
    end

  end

end