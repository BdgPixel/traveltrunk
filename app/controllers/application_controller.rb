class ApplicationController < ActionController::Base
  hide_action :current_user
  before_action :get_unread_notification_count
  before_action :authenticate

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  protected
    def after_sign_in_path_for(resource)
      if resource.admin?
       admin_promo_codes_url
      else
        root_url
      end
    end

    def get_unread_notification_count
      @notification_count = current_user.get_notification(false).count if user_signed_in?
    end

    def authenticate
      authenticate_or_request_with_http_basic do |username, password|
        username == "traveltrunk" && password == "A8BzR2YKnguxWZz"
      end
    end
end
