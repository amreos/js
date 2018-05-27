class PublicJobsController < ApplicationController  
  layout 'public'

  def index
    options = params.dup
    options[:page] ||= 1
    options[:limit] = 12

    @public_jobs = Job.
                    open.
                    where(:featured => true).
                    only(:_id, :job_type, :name, :employee_id, :summary, :industry, :general_area, :loc, :state).
                    asc(:job_type).
                    page(options[:page]).
                    per(options[:limit])
        
  end
  
  def show
    @public_job = Job.
                    open.
                    where(:featured => true, :_id => params[:id]).
                    only(:_id, :job_type, :employee_id, :benefits, :licenses, :summary, :description, :industry, :general_area, :loc, :name).first
    
    if @public_job.blank?
      redirect_to public_jobs_path, :notice => "Sorry, that job is no longer available" 
    end
  end
  
end