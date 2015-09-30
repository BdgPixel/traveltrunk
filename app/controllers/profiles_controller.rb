class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profile, only: [:show]

  def show; end

  def edit
    current_user.build_profile unless current_user.profile
    current_user.build_bank_account unless current_user.bank_account
  end

  def update
    respond_to do |format|
      if current_user.update_attributes(user_params)
        format.html { redirect_to profile_url, notice: 'Profile was successfully updated.' }
        format.json { render :show }
      else
        format.html { render :edit }
        format.json { render json: current_user.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def set_profile

      unless current_user.profile
        redirect_to edit_profile_path, alert: "You haven't entered your profile. \n
          Please fill information below"
      end
    end

    def user_params
      params.require(:user).permit(profile_attributes: [:first_name, :last_name, :birth_date, :gender, :address,
        :address_1, :address_2, :city, :state, :postal_code, :country_code, :image, :image_cache],
        bank_account_attributes: [:bank_name, :account_number, :routing_number, :amount_transfer]
        )
    end
end
