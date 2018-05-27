class WorkHistoriesController < ApplicationController
  before_filter :authenticate_employee!
  before_filter :load_candidate
  layout 'manage'

  def index

    if params[:name]
      term = escape_term(params[:name])
      work_histories = @candidate.work_histories.only(:name, :id).limit(10).where(:name => /#{term}*/i).asc(:name)

      results = work_histories.map { |f| { :label => f.name, :value => f.name, :id => f.id } }
    end

    respond_to do |format|
      format.html { redirect_to @candidate }
      format.js { render :json => results }
    end

  end

  def show
    @work_history = @candidate.work_histories.find(params[:id])

    respond_to do |format|
      unless @work_history.blank?
        format.js
      else
        flash[:alert] = "Not Found. Please try again."
        format.js { render 'shared/error' }
      end
    end
  end

  def new
    @work_history = @candidate.work_histories.build
  end

  def edit
    @work_history = @candidate.work_histories.find(params[:id])
  end

  def create
    @work_history = @candidate.work_histories.create(params[:work_history])

    if @work_history.save
      redirect_to(@candidate, :notice => 'Work History was successfully created.')
    else
      render :action => "new"
    end
  end

  def update
    @work_history = @candidate.work_histories.find(params[:id])

    params[:work_history][:mix_types]     ||= []
    params[:work_history][:special_units] ||= []

    if @work_history.update_attributes(params[:work_history])
      redirect_to(@candidate, :notice => 'Work History was successfully updated.')
    else
      render :action => "edit"
    end

  end

  def delete
    @work_history = @candidate.work_histories.find(params[:id])
  end

  # DELETE /candidates/1/work_histories/1
  def destroy

    @work_history = @candidate.work_histories.find(params[:id])
    @work_history.destroy

    respond_to do |format|
      format.html { redirect_to(@candidate, :notice => 'Work History was successfully Deleted.') }
      format.js { render 'shared/destroy_success', :notice => 'Work History was successfully Deleted.' }
    end
  end

  private

  def load_candidate
    @candidate = Candidate.find(params[:candidate_id])
  end

end
