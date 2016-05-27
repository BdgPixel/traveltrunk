class Admin::UsersController < Admin::ApplicationController
  before_action :set_user, only: [:show]
  before_action :authenticate_user!

  def index
    @users = User.non_admin.page params[:page]
  end

  def show; end

  private
    def set_user
      @user = User.find params[:id]
    end
end
