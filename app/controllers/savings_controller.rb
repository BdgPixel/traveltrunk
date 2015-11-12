class SavingsController < ApplicationController
  def index
    if current_user.group
      @members = current_user.group.members.select(:id, :email)
    end
    @joined_groups = current_user.joined_groups
    # yuhuu
  end
end
