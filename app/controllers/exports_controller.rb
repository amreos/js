class ExportsController < ApplicationController
  before_filter :authenticate_admin!

  ALLOWED_EXPORTS = %w(client candidate job)

  def index
  	if ALLOWED_EXPORTS.include? params[:export_type]
  		klass = params[:export_type]

  		Resque.enqueue(ResqueExportNotification, current_user.id, params)

	    respond_to do |format|
	      flash[:notice] = "Exporting #{klass.titlecase.pluralize} - You will recieve an email shortly"
	      format.html { redirect_to(clients_url) }
	      format.js { render 'shared/destroy_success' }
	    end
  	else
	    respond_to do |format|
	      flash[:alert] = "Cannot Process Your Export"
	      format.html { redirect_to(clients_url) }
	      format.js { render 'shared/error' }
	  	end
	  end
  end
end