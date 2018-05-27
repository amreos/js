class ResumesController < ApplicationController
  before_filter :authenticate_employee!
  before_filter :load_candidate
  layout 'manage'

  def index

  end

  def new
    @resume = @candidate.resumes.build
  end

  def show
    @resume = @candidate.resumes.find(params[:id])
    @work_histories = @candidate.work_histories.where(:_id.in => @resume.work_history_ids).all

    respond_to do |format|
      format.html
      format.pdf { send_data(@resume.generated_pdf, :filename => "#{@resume.name}.pdf", :type => 'pdf') }
    end
  end

  def generate
    @resume = @candidate.resumes.find(params[:id])
    @work_histories = @candidate.work_histories.where(:_id.in => @resume.work_history_ids).all

    @resume.rendered_html = render_to_string('generate.pdf', :layout => 'resume')
    @resume.currently_rendering = true

    respond_to do |format|
      if @resume.save
        Resque.enqueue(Resume, @resume.id)
        flash[:notice] = "Generating Resume..."
        format.js
      else
        flash[:alert] = "Could not Generate Resume"
        format.js { render 'shared/error' }
      end
    end

  end

  def edit
    @resume = @candidate.resumes.find(params[:id])
  end

  def create
    @resume = @candidate.resumes.create(params[:resume])

    if @resume.save
      redirect_to([@candidate, @resume], :notice => 'Resume was successfully created.')
    else
      render :action => "new"
    end
  end

  def update
    @resume = @candidate.resumes.find(params[:id])

    params[:resume][:work_history_ids] ||= []

    if @resume.update_attributes(params[:resume])
      redirect_to([@candidate, @resume], :notice => 'Resume was successfully updated.')
    else
      render :action => "edit"
    end
  end

  def destroy
    @resume = @candidate.resumes.find(params[:id])
    @resume.destroy

    respond_to do |format|
      format.html { redirect_to(@candidate, :notice => 'Resume was successfully Deleted.') }
      format.js { render 'shared/destroy_success', :notice => 'Resume was successfully Deleted.' }
    end
  end

  private

  def load_candidate
    @candidate = Candidate.find(params[:candidate_id])
  end
end
