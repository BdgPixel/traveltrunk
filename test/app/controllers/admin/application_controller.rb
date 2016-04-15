class Admin::ApplicationController < ActionController::Base
  layout 'application'

  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :authenticate_admin!

  def authenticate_admin!
    if user_signed_in?
      unless current_user.admin?
        redirect_to savings_url
      end
    else
      root_url
    end
  end

end
