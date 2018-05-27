class JobInquiriesController < ApplicationController
	layout 'public'
	before_filter :load_job

	def index
		redirect_to public_jobs_path		
	end

	def new
		if @public_job.present?
			@job_inquiry = JobInquiry.new
			@job_inquiry.job_id = @public_job.id
		else
			redirect_to public_jobs_path, :alert => "Could not find the job to inquire"
		end	      
	end

	def create
		if @public_job.present?
			@job_inquiry = JobInquiry.new
			@job_inquiry.job_id = @public_job.id

			params[:job_inquiry].delete :job_id
			@job_inquiry.attributes = params[:job_inquiry]

			if @job_inquiry.save
				Resque.enqueue(ResqueJobInquiryNotification, @job_inquiry.id)				
				redirect_to candidate_thank_you_path

			else
				render 'new'
			end
		else
			redirect_to public_jobs_path, :alert => "Could not find the job to inquire"
		end	      			
	end

private
	def load_job
		@public_job = Job.
                    open.
                    where(:featured => true, :_id => params[:id]).
                    only(:_id, :job_type, :general_area, :name).first
	end

end