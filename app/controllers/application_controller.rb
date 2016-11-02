class ApplicationController < ActionController::Base
  hide_action :current_user
  before_action :get_unread_notification_count
  before_action :authenticate_page
  before_action :set_request_headers
  before_action :get_messages

  protect_from_forgery with: :exception

  layout :layout_by_resource

  def get_group
    if user_signed_in?
      @group = current_user.group || current_user.joined_groups.first
    end
  end

  def set_action_form_search
    @method_name, @is_remote =
      if user_signed_in?
        [:post, true]
      else
        [:get, false]
      end
  end

  def get_messages
    unless request.xhr?
      if user_signed_in?
        @messages = current_user.messages.conversations
        
        # unless @messages.first.sent_messageable_id.eql? current_user.id
        @message_count = current_user.received_messages.conversations.select{ |c| !c.opened }.count
        # end
      end
    end
  end

  protected
    def layout_by_resource
      if devise_controller?
        'bg_gradient_navbar'
      else
        'application'
      end
    end

    def after_sign_in_path_for(resource)
      if resource.admin?
        admin_promo_codes_url
      else
        deals_url
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

    def set_request_headers
      Expedia::Hotels.set_request_headers =
        { customer_ip: request.remote_addr, customer_user_agent: request.user_agent }
    end
end
