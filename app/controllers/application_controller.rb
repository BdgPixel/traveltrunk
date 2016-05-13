class ApplicationController < ActionController::Base
  hide_action :current_user
  before_action :get_unread_notification_count
  # before_action :authenticate
  before_action :authenticate_page

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  layout :layout_by_resource

  def get_group
    if user_signed_in?
      @group = current_user.group || current_user.joined_groups.first
    end
  end

  protected
    def layout_by_resource
      if devise_controller?
        if (['sessions', 'confirmations', 'passwords'].include?(controller_name) && action_name.eql?('new')) || (controller_name.eql?('registrations') && ['new', 'create'].include?(action_name))
          'bg_gradient_no_navbar'
        else
          'application'
        end
      else
        'application'
      end
    end

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
        username == "traveltrunk" && password == "TrunkTest16"
      end
    end

    def authenticate_page
      if user_signed_in? && current_user.try(:admin?) && !devise_controller?
        redirect_to admin_users_url
      end
    end
end
