class Admin::ApplicationController < ActionController::Base
  layout 'application'

  protect_from_forgery with: :exception
  before_action :authenticate_admin!

  def authenticate_admin!
    unless current_user.admin?
      redirect_to savings_url
    end
  end

end
