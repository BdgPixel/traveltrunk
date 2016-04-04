class SavingsController < ApplicationController
  require 'expedia'

  before_action :authenticate_user!
  before_action :get_group, only: :index
  before_action :check_saving_plan, only: :index

  def index; end

  private
    def check_saving_plan
      unless current_user.bank_account
        redirect_to edit_profile_path, notice: 'Please complete the profile before you can access savings page'
      end
    end
end
