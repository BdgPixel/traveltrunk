class SavingsController < ApplicationController
  before_action :authenticate_user!

  def index
    if current_user.profile && current_user.bank_account
      if current_user.group
        @members = current_user.group.members.select(:id, :email, :total_credit)
        @group_total_credit = current_user.group.total_credit
      end
      @joined_groups = current_user.joined_groups
    else
      @error_message = "Please complete the profile"
    end

  end
end
