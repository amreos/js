class ContentsController < ApplicationController
  before_filter :authenticate_employee!, :only => [:dashboard]
  layout 'application'

  def home
    @jobs = Job.open.where(:featured => true).limit(8).
                only(:_id, :name, :job_type, :name, :general_area, :summary, :employee_id, :updated_at, :loc).desc(:updated_at)

    render :layout => "home"
  end

  def newsletters
    render :layout => 'public'
  end

  def employers
    render :layout => 'public'
  end

  def healthcare
    render :layout => 'public'
  end

  def interim
    render :layout => 'public'
  end

  def consulting
    render :layout => 'public'
  end

  def finance
    render :layout => 'public'
  end

  def candidates
    render :layout => 'public'
  end

  def advice
    render :layout => 'public'
  end

  def resume_services
    render :layout => 'public'
  end

  def about
    render :layout => 'public'
  end

  def contact
    render :layout => 'public'
  end

  def client_thanks
    render :layout => 'public'
  end

  def candidate_thanks
    render :layout => 'public'
  end

  def dashboard
    options = params.dup
    options[:page] ||= 1
    options[:limit] = 20

    @my_recent_jobs = current_user.jobs.where(:state.nin => [0,4,5,6,7]).limit(10).desc(:updated_at)
    @my_recent_candidates = current_user.candidates.where(:state.nin => [0,4,5]).limit(10).desc(:updated_at)
    @activities = Activity.desc(:created_at).page(options[:page]).per(options[:limit])

    render :layout => 'manage'

  end

end