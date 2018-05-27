class ApplicantsController < ApplicationController
  before_filter :authenticate_employee!

  ALLOWED_PARENT_TYPES = %w{Candidate Job}

  def create
    if params[:app_job_id].present? && params[:app_candidate_id].present?
      @parent = params[:app_parent_type] if ALLOWED_PARENT_TYPES.include? params[:app_parent_type]
      @job = Job.where(:_id => params[:app_job_id]).first
      @candidate = Candidate.where(:_id => params[:app_candidate_id]).first

      if @job.present? && @job.state != 0 && @candidate.present? && @candidate.available? && @parent.present?

        @applicant = Applicant.new(:job_id => @job.id,
                                   :candidate_id => params[:app_candidate_id],
                                   :client_id => @job.client_id,
                                   :employee_id => @job.employee_id)

        respond_to do |format|
          if @applicant.save
            flash[:notice] = "Candidate added to job"
            format.js
          else
            message = @applicant.errors.full_messages.first || "Could not add Candidate to Job"
            flash[:alert] = message
            format.js { render 'shared/error' }
          end
        end

      else
        respond_to do |format|
          flash[:alert] = "Job or Candidate is already placed, on hold or flagged"
          format.js { render 'shared/error' }
        end
      end
    else
      respond_to do |format|
        flash[:alert] = "Be sure to select a job or candidate before adding."
        format.js { render 'shared/error' }
      end
    end

  end

  def mass_create
    @job = Job.where(:_id => params[:app_job_id]).first            if params[:app_job_id].present?
    @candidates = Candidate.where(:_id.in => params[:selected_candidates])     if params[:selected_candidates].present?

    if @job.present? && @job.state != 0 && @candidates.present?
      @candidates.each do |candidate|
        @applicant = Applicant.create(:job_id => @job.id,
                                      :candidate_id => candidate.id,
                                      :client_id => @job.client_id,
                                      :employee_id => @job.employee_id) if candidate.available?
      end
      respond_to do |format|
        flash[:notice] = "Candidates added to Job"
        format.js
      end
    else
      respond_to do |format|
        flash[:alert] = "Please Select Candidates or Try Another Job"
        format.js { render 'shared/error' }
      end
    end
  end

  def destroy
    @applicant = Applicant.find(params[:id])

    if @applicant.applicant_placed?
      respond_to do |format|
        flash[:alert] = "Placed Candidates Cannot Be Removed from Job"
        format.html { redirect_to(jobs_url) }
        format.js { render 'shared/error' }
      end
    else
      @applicant.destroy
      respond_to do |format|
        flash[:notice] = "Candidate Removed from Job"
        format.html { redirect_to(jobs_url) }
        format.js { render 'shared/destroy_success' }
      end
    end

  end

  def update_status
    status = params[:new_status]
    @applicant = Applicant.find(params[:id])

    respond_to do |format|
      if @applicant.update_attributes(:state => status)
        Activity.notify(current_user.name,
                        current_user.id, 3, 7,
                        @applicant.candidate_id,
                        "#{@applicant.candidate.name}'s Progress", @applicant.current_state)

        flash[:notice] = "Status Updated"
        format.js
      else
        message = @applicant.errors.full_messages.first || "Not a correct status"
        flash[:alert] = message
        format.js { render 'shared/error' }
      end
    end
  end

end