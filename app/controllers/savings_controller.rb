class SavingsController < ApplicationController
  def index
    if current_user.profile && current_user.bank_account
      if current_user.group
        puts 'hehe'
        @members = current_user.group.members.select(:id, :email) if current_user.group
      end
      @joined_groups = current_user.joined_groups
    else
      @error_message = "Please complete the profile"
    end
  end
end
