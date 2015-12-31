class Users::InvitationsController < Devise::InvitationsController
  def edit
    resource.build_profile
    set_minimum_password_length
    yield resource if block_given?
    respond_with self.resource
  end

  private
    def update_resource_params
      params.require(:user).permit(:id, :email, :password, :password_confirmation, :invitation_token, :group_id, profile_attributes: [:first_name, :last_name])
    end

    def accept_resource
      resource = resource_class.accept_invitation!(update_resource_params)
      UsersGroup.create(user_id: params[:user][:id], group_id: params[:user][:group_id])
      ## Report accepting invitation to analytics
      # Analytics.report('invite.accept', resource.id)
      resource
    end
end
