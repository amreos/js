class TasksController < ApplicationController
  before_filter :authenticate_employee!
  layout 'manage'

  def index
  	@tasks = current_user.tasks.list_tasks(params)
  end

  def show
  	@task = current_user.tasks.find(params[:id])
  end

  def new
  	@task = current_user.tasks.new
    @task.task_date = 1.day.from_now.in_time_zone(current_user.time_zone).strftime('%B %d, %Y')
    @task.task_time = "8am"

    @task.goal_id = params[:goal_id]                   if params[:goal_id].present?
    @task.goal_type = params[:goal_type]               if params[:goal_type].present?
    @task.goal_parent_type = params[:goal_parent_type] if params[:goal_parent_type].present?
    @task.goal_parent_id = params[:goal_parent_id]     if params[:goal_parent_id].present?

    respond_to do |format|
      format.html { redirect_to tasks_path, alert: "Please make sure Javascript is enabled" }
      format.js   { }
    end
  end

  def create
  	@task = current_user.tasks.new(params[:task])

  	if @task.save
  		flash[:notice] = "Successfully Created Your Task"

      respond_to do |format|
  			format.html { redirect_to tasks_path }
  			format.js   { render 'success' }
  		end
  	else
  		flash[:alert] = @task.errors.full_messages.first || "Could not save your task. Please Try Again."
  		respond_to do |format|
  			format.html { redirect_to tasks_path }
  			format.js   { render 'error' }
  		end
  	end
  end

  def edit
    @task = current_user.tasks.find(params[:id])

    respond_to do |format|
      format.html { redirect_to tasks_path, alert: "Please make sure Javascript is enabled" }
      format.js   { render 'new' }
    end
  end

  def update
    @task = current_user.tasks.find(params[:id])

    if @task.update_attributes(params[:task])
      flash[:notice] = "Successfully Updated Your Task"

      respond_to do |format|
        format.html { redirect_to tasks_path }
        format.js
      end
    else
      flash[:alert] = @task.errors.full_messages.first || "Could not save your task. Please Try Again."
      respond_to do |format|
        format.html { redirect_to tasks_path }
        format.js   { render 'error' }
      end
    end
  end

  def finish
  	@task = current_user.tasks.find(params[:id])
  	if @task.update_attribute(:completed, true)
  		flash[:notice] = "Your Task is Marked as Completed"

      respond_to do |format|
        format.html { redirect_to tasks_path }
        format.js { render 'finnish' }
      end
  	else
  	  flash[:alert] = "Could Not Complete Task. Please Try Again"

      respond_to do |format|
        format.html { redirect_to tasks_path }
        format.js   { render 'error' }
      end
  	end
  end

  def destroy
    if admin?
      @task = Task.find(params[:id])
    else
      @task = current_user.tasks.find(params[:id])
    end
    @task.destroy

    respond_to do |format|
      flash[:notice] = "Task Destroyed"
      format.html { redirect_to dashboard_path }
      format.js { render 'finnish' }
    end
  end
end