class Users::InvitationsController < Devise::InvitationsController
  def edit
    resource.build_profile
    set_minimum_password_length if respond_to? :set_minimum_password_length
    resource.invitation_token = params[:invitation_token]
    render :edit
  end

  def update
    raw_invitation_token = update_resource_params[:invitation_token]
    self.resource = accept_resource
    self.resource.build_profile(update_resource_params[:profile_attributes])
    invitation_accepted = resource.errors.empty?

    yield resource if block_given?

    if invitation_accepted
      UserMailer.welcome(resource).deliver_now
      if Devise.allow_insecure_sign_in_after_accept
        flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
        set_flash_message :notice, flash_message if is_flashing_format?
        sign_in(resource_name, resource)
        respond_with resource, :location => after_accept_path_for(resource)
      else
        set_flash_message :notice, :updated_not_active if is_flashing_format?
        respond_with resource, :location => new_session_path(resource_name)
      end
    else
      resource.invitation_token = raw_invitation_token
      respond_with_navigational(resource){ render :edit }
    end
  end

  private
    def update_resource_params
      params.require(:user).permit(:email, :password, :password_confirmation, :invitation_token, profile_attributes: [:first_name, :last_name])
    end
end
