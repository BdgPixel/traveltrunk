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

  def create
    build_resource(sign_up_params)
    resource.save
    yield resource if block_given?
    
    if resource.persisted?
      if session[:destination].present?
        Destination.create(session_destination_params(resource.id))
      end

      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  protected
    def sign_up_params
      params.require(:user).permit(:email, :password, :password_confirmation,
        profile_attributes: [:first_name, :last_name, :birth_date])
    end

    def session_destination_params(user_id)
      session[:destination].symbolize_keys.merge(
        destinationable_id: user_id,
        destinationable_type: 'User',
      )
    end
end
