class ApplicationController < ActionController::Base
  hide_action :current_user
  before_action :get_unread_notification_count
  http_basic_authenticate_with name: "maryssa", password: "traveltrunk"

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def after_sign_in_path_for(resource)
    root_path
  end

  def get_unread_notification_count
    @notification_count = current_user.get_notification(false).count if user_signed_in?
  end

end
