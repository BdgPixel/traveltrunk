class RegistrationsController < Devise::RegistrationsController
  def after_inactive_sign_up_path_for(resource)
    new_user_session_url
  end

  def new
    build_resource({})
    resource.build_profile
    set_minimum_password_length
    yield resource if block_given?
    respond_with self.resource
  end

  def sign_up(resource_name, resource)
    sign_in(resource_name, resource)
  end

  protected
    def sign_up_params
      params.require(:user).permit(:email, :password, :password_confirmation,
        profile_attributes: [:first_name, :last_name])
    end
end
