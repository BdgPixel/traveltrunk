class SavingsController < ApplicationController
  before_action :authenticate_user!
  before_action :get_group, only: :index

  def index
    unless current_user.profile.home_airport && current_user.bank_account
      redirect_to edit_profile_url
    end
  end
end
