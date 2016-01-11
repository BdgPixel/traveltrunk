class Admin::ListUsersController < ApplicationController
  before_action :set_user, only: [:show]

  def index
    @users = User.all.where(admin: false)
  end

  def show

  end

  private
    def set_user
      @user = User.find params[:id]
    end

end
