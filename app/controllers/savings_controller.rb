class SavingsController < ApplicationController
  before_action :authenticate_user!
  before_action :get_group, only: :index

  def index
    unless current_user.profile && current_user.bank_account
      @error_message = "Please complete the profile"
    end
  end
end
