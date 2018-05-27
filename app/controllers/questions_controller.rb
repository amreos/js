class QuestionsController < ApplicationController
  respond_to :js
  
  def new
    @question = Question.new
    @question.job_id = params[:job_id] if params[:job_id].present?
    @question.employee_id = params[:jsa_id] if params[:employee_id].present?    
    
    respond_to do |format|
      format.js
      format.html { redirect_to contact_path, :alert => "Please Enable JavaScript"}
    end
  end
  
  def create        
    @question = Question.new(params[:question])    
    
    if @question.save
      flash[:notice] = "Thank You, We will respnd to you soon"
      Resque.enqueue(Question, @question.id)
    else
      flash[:alert] = @question.errors.full_messages.first || "Please enter your name, email, and question"
      render :partial => 'error'
    end
  end
  
end