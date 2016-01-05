class GroupsController < ApplicationController
  before_action :authenticate_user!

  def users_collection
    users_list = User.get_autocomplete_data(params[:q], current_user.id)

    respond_to do |format|
      format.json { render json: users_list }
    end
  end

  def invite
    group = current_user.group || current_user.joined_groups.first

    unless group
      group = Group.create(name: "Your Group's Savings", user_id: current_user.id)
    end

    invitation_params = params[:invite][:user_id].split(',')

    if invitation_params.empty?
      redirect_to savings_path, alert: 'You should provide user email or choose from existing users from suggestion to invite'
    else
      # check if array element is string id or string email
      invitation_params = invitation_params.group_by { |param| !/\A\d+\z/.match(param) ? 'emails' : 'ids' }

      # check users invite if users have group or not
      existing_emails = []
      existing_emails_error = ''
      User.select(:id, :email).where(email: invitation_params['emails']) .each do |user|
        if user.users_groups
          existing_emails = [user.email]
          existing_emails_error = "but email #{existing_emails.join(',')} already registered."
        end
      end

      email_success = []
      if emails = invitation_params['emails']
        emails = emails - existing_emails

        emails.each do |email|
          user_invite = User.invite!({ email: email }, current_user) do
            UsersGroup.create(user_id: user_invite.id, group_id: current_user.id)
            email_success += [email]
          end
        end
      end

      if ids = invitation_params['ids']
        group_hashs = ids.map { |id| { user_id: id, group_id: group.id } }
        users_groups = UsersGroup.create(group_hashs)
      end

      redirect_to savings_path, notice: "#{email_success.count + ids.count} User was successfully invited #{existing_emails_error}"
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

  def leave_group
    if current_user.group
      group = current_user.group
    else
      group = current_user.users_groups.find_by(group_id: params[:id], user_id: current_user)
    end

    if group.destroy
      redirect_to savings_url, notice: 'You have been leave the group'
    else
      redirect_to savings_url, notice: 'Some errors occurred when leave the group'
    end
  end

end
