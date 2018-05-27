class ApplicationController < ActionController::Base
  include EscapeRegexTerms
  protect_from_forgery

  before_filter :set_user_time_zone

  helper_method :admin?, :employee?, :client?, :candidate?, :escape_term

  def valid_generic_email(email, parent = nil)
    if ( email.present? && email =~ /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i ) || email.blank?
      true
    else
      parent.errors[:base] << "Please a Correct Email Address" if parent.present?
      false
    end
  end

  private

  def set_user_time_zone
    if user_signed_in?
      Time.zone = current_user.time_zone
    else
      Time.zone = 'Pacific Time (US & Canada)'
    end
  end

  def escape_term(term)
    EscapeRegexTerms.escape_term(term)
  end

  def after_sign_in_path_for(resource_or_scope)
    case current_user.class
      when Employee then manage_dashboard_path
      when Candidate then candidate_thank_you_path
      when Client then client_thank_you_path
    end
  end

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end

  def admin?
    user_signed_in? && current_user.admin?
  end

  def employee?
    user_signed_in? && current_user.class == Employee
  end

  def client?
    user_signed_in? && current_user.class == Client
  end

  def candidate?
    user_signed_in? && current_user.class == Candidate
  end

  def authenticate_employee!
    unless employee?
      respond_to do |format|
        flash[:alert] = "You are not authorized to access that page or request"
        format.html { redirect_to new_user_session_path }
        format.js { render 'shared/error' }
      end
    end
  end

  def authenticate_candidate!
    unless candidate? || employee?
      respond_to do |format|
        flash[:alert] = "You are not authorized to access that page or request"
        format.html { redirect_to root_path }
        format.js { render 'shared/error' }
      end
    end
  end

  def authenticate_client!
    unless client? || employee?
      respond_to do |format|
        flash[:alert] = "You are not authorized to access that page or request"
        format.html { redirect_to root_path }
        format.js { render 'shared/error' }
      end
    end
  end

  def authenticate_admin!
    unless admin?
      respond_to do |format|
        flash[:alert] = "You are not authorized to access that page or request"
        format.html { redirect_to root_path }
        format.js { render 'shared/error' }
      end
    end
  end

end
