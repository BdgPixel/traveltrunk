class Users::InvitationsController < Devise::InvitationsController
  # before_filter :configure_permitted_parameters, if: :devise_controller?
  # before_filter :update_sanitized_params, only: :update
  # before_action :devise_configure_permitted_parameters, if: :devise_controller?

  def edit
    # build_resource({})
    # yuhuu
    resource.build_profile
    set_minimum_password_length
    yield resource if block_given?
    respond_with self.resource
  end

  # def update
  #   user = User.accept_invitation!(update_resource_params)
  #   # binding.pry
  #   # respond_to do |format|
  #   #   wew
  #   #   format.js do
  #   #     invitation_token = Devise.token_generator.digest(resource_class, :invitation_token, update_resource_params[:invitation_token])
  #   #     self.resource = resource_class.where(invitation_token: invitation_token).first
  #   #     resource.skip_password = true
  #   #     resource.update_attributes update_resource_params.except(:invitation_token)
  #   #   end
  #   #   format.html do
  #   #     super
  #   #   end
  #   # end
  # end

  private
    def update_resource_params
      params.require(:user).permit(:id, :email, :password, :password_confirmation, :invitation_token, :group_id, profile_attributes: [:first_name, :last_name])
    end

    # def devise_configure_permitted_parameters
    #   # devise_parameter_sanitizer.for(:accept_invitation) << [:first_name, :last_name]
    #   devise_parameter_sanitizer.for(:accept_invitation).concat [:first_name, :last_name]
    #   devise_parameter_sanitizer.for(:accept_invitation) do |u|
    #     u.permit(:id, :email, :password, :password_confirmation, :invitation_token, :group_id)
    #   end
    # end

    # def update_sanitized_params
    #   @resource = User.find params[:user][:id]
    #   # devise_parameter_sanitizer.for(:user) do |u|
    #   #   u.permit(:id, :email, :password, :password_confirmation, :invitation_token, :group_id, profile_attributes: [:first_name, :last_name])
    #   # end
    # end


    # def build_resource(hash = nil)
    #   # yuhuu
    #   hash ||= resource_params || {}
    #   if hash[:email]
    #     self.resource = resource_class.where(:email => hash[:email]).first
    #     if self.resource && self.resource.respond_to?(:invited_to_sign_up?) && self.resource.invited_to_sign_up?
    #       self.resource.attributes = hash
    #       self.resource.send_confirmation_instructions if self.resource.confirmation_required_for_invited?
    #       self.resource.accept_invitation
    #     else
    #       self.resource = nil
    #     end
    #   end
    #   # self.resource ||= super
    # end

    def accept_resource
      # yuhuu
      resource = resource_class.accept_invitation!(update_resource_params)
      UsersGroup.create(user_id: params[:user][:id], group_id: params[:user][:group_id])
      ## Report accepting invitation to analytics
      # Analytics.report('invite.accept', resource.id)
      resource
      # binding.pry
    end
end
