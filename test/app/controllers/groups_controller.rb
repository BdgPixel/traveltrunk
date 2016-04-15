class GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :get_group, only: [:invite, :leave_group]

  def users_collection
    users_list = User.get_autocomplete_data(params[:q], current_user.id)

    respond_to do |format|
      format.json { render json: users_list }
    end
  end

  def invite
    unless @group
      @group = Group.create(name: "Your Group's Savings", user_id: current_user.id)
    end

    invitation_params = params[:invite][:user_id].split(',')

    if invitation_params.empty?
      redirect_to savings_path, alert: 'You should provide user email or choose from existing users from suggestion to invite.'
    elsif invitation_params.size > 4
      redirect_to savings_path, alert: 'You can only invite max 4 users to your group savings.'
    else
      # check if array element is string id or string email
      invitation_params = invitation_params.group_by { |param| !/\A\d+\z/.match(param) ? 'emails' : 'ids' }

      # check users invite if users have group or not
      invited_users_count = 0
      existing_emails = []

      if emails = invitation_params['emails']
        existing_user_emails = User.select(:id, :email).where(email: invitation_params['emails']).map(&:email)

        emails.each do |email|
          if existing_user_emails.include? email
            existing_emails << email
          else
            invited_user = User.invite!({ email: email }, current_user)
            UsersGroup.create(user_id: invited_user.id, group_id: @group.id)
            invited_users_count += 1
          end
        end
      end

      if ids = invitation_params['ids']
        group_hashs = ids.map { |id| { user_id: id, group_id: @group.id } }
        users_groups = UsersGroup.create(group_hashs)
        invited_users_count += ids.size
      end

      notice = "#{invited_users_count} User was successfully invited."
      notice << " #{existing_emails.join(', ')} can't be invited because already registered" unless existing_emails.empty?
      redirect_to savings_path, notice: notice
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
    unless @group.user_id.eql? current_user.id
      @group = current_user.users_groups.find_by(group_id: params[:id], user_id: current_user)
    end

    if @group.destroy
      redirect_to savings_url, notice: 'You have been leave the group'
    else
      redirect_to savings_url, notice: 'Some errors occurred when leave the group'
    end
  end

end
