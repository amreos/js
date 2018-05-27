class ActivitiesController < ApplicationController
  before_filter :authenticate_admin!
  layout 'manage'

  def index
  	@activities = Activity.advanced_search(params)
  end
end