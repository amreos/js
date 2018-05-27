class ResumeSubmissionsController < ApplicationController
	layout 'public'
	
	def index
		redirect_to about_candidates_path		
	end

	def new
		@resume_submission = ResumeSubmission.new
		@resume_submission.attachments.build()
	end

	def create		
		@resume_submission = ResumeSubmission.new(params[:resume_submission])

		if @resume_submission.save
			@resume_submission.attachments.map(&:save)
			Resque.enqueue(ResqueResumeSubmissionNotification, @resume_submission.id)
			redirect_to candidate_thank_you_path

		else
			@resume_submission.attachments.build() if @resume_submission.attachments.blank?
			render 'new'
		end
	end

end