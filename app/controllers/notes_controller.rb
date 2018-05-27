class NotesController < ApplicationController
  before_filter :authenticate_employee!
  before_filter :authenticate_admin!, :only => [:destroy]

  def show
    @note = Note.find(params[:id])

    respond_to do |format|
      format.js
    end
  end

  def create
    @note = Note.new(params[:note])
    @parent_name = params[:parent_name]
    @parent_klass = params[:parent_klass]

    if @note.save
      Activity.notify(current_user.name, current_user.id, 0, 6, @note.id, @parent_name, @parent_klass)
      respond_to do |format|
        flash[:notice] = "Note Successfully Added"
        format.html { redirect_to @parent  }
        format.js
      end
    else
      respond_to do |format|
        flash[:alert] = "Could Not Create Note. Please Try Again"
        format.html { redirect_to @parent }
        format.js {render 'shared/error'}
      end
    end
  end

  def destroy
    @note = Note.find(params[:id])
    @note.destroy

    respond_to do |format|
      flash[:notice] = "Note Destroyed"
      format.html { redirect_to dashboard_path }
      format.js { render 'shared/destroy_success' }
    end
  end

end