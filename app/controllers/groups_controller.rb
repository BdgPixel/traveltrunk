class GroupsController < ApplicationController
  before_action :authenticate_user!

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

    invitation_params = params[:invite][:user_id].split(',')

    if invitation_params.empty?
      redirect_to savings_path, alert: 'You should provide user email or choose from existing users from suggestion to invite'
    else
      # check if array element is string id or string email
      invitation_params = invitation_params.group_by { |param| !/\A\d+\z/.match(param) ? 'emails' : 'ids' }

      if emails = invitation_params['emails']
        emails.each do |email|
          puts email
          # binding.pry
          User.invite!({ email: email }, current_user)
        end
      end

      if ids = invitation_params['ids']
        group_hashs = ids.map { |id| { user_id: id, group_id: group.id } }
        users_groups = UsersGroup.create(group_hashs)
      end

      redirect_to savings_path, notice: 'User was successfully invited.'
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
