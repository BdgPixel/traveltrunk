class Admin::UsersController < Admin::ApplicationController
  before_action :set_user, only: [:show, :update]
  before_action :authenticate_user!

  def index
    @users = User.non_admin.page params[:page]
  end

  def show; end

  def update
    if @user.update(user_params)
      redirect_to admin_users_url, notice: 'Amount was successfully updated.'
    else
      redirect_to admin_users_url, alert: 'Amount was unsuccessfully updated.'
    end
  end

  private
    def set_user
      @user = User.find params[:id]
    end

    def user_params
      current_params = params.require(:user).permit(:total_credit)
      current_params[:total_credit] = current_params[:total_credit].to_f * 100
      current_params
    end
end
