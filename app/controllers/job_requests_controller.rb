class JobRequestsController < ApplicationController
	layout 'public'
	
	def index
		redirect_to employers_path		
	end

	def new
		@job_request = JobRequest.new
		@job_request.attachments.build()
	end

	def create		
		@job_request = JobRequest.new(params[:job_request])		

		if @job_request.save
			@job_request.attachments.map(&:save)
			Resque.enqueue(ResqueJobRequestNotification, @job_request.id)
			redirect_to client_thank_you_path

		else
			@job_request.attachments.build() if @job_request.attachments.blank?
			render 'new'
		end
	end

end