class SavingsController < ApplicationController
  def index
    if current_user.group
      @members = current_user.group.members.select(:id, :email)
      # @joined_members = @members.map { |u| { id: u.id, name: u.email } }
    end
    @joined_groups = current_user.joined_groups
    # yuhuu
  end
end
