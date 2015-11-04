class GroupsController < ApplicationController
  def users_collection
    users_list = User.get_autocomplete_data(params[:q], current_user.id)

    respond_to do |format|
      format.json { render json: users_list }
    end
  end

  def invite
    group = current_user.group

    unless group
      group = Group.create(name: "Your Group's Savings", user_id: current_user.id)
    end

    group_hashs = params[:invite][:user_id].split(',').uniq
      .map { |u| { user_id: u, group_id: group.id } }

    users_groups = UsersGroup.create(group_hashs)

    respond_to do |format|
      format.html { redirect_to savings_path, notice: 'User was successfully invited.' }
      format.json { render :show, status: :created }
    end
  end

  def accept_invitation
    user_group = UsersGroup.find_by(invitation_token: params[:token])
    user_group.accept_invitation

    respond_to do |format|
      if user_group.update_attributes(accepted_at: Time.now)
        format.html { redirect_to savings_path, notice: 'You were successfully join the group.' }
        format.json { render :show, status: :ok}
      end
    end

  end
end
