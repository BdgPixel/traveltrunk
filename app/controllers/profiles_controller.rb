class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profile, only: [:show]

  def show
    @hide_informations = false
    if params[:id]
      @hide_informations = true
    else
      @hide_informations = false
    end
  end

  def edit
    current_user.build_profile unless current_user.profile
    # current_user.build_bank_account unless current_user.bank_account
    @bank_account = current_user.bank_account || current_user.build_bank_account
  end

  def update
    @bank_account = current_user.bank_account || current_user.build_bank_account

    current_user.profile.validate_personal_information = true

    if current_user.update_attributes(user_params)
      redirect_to profile_url, notice: 'Profile was successfully updated.'
    else
      render :edit
    end
  end

  def create_bank_account
    # custom_params = bank_account_params.merge({ stripe_token: params[:stripeToken] })
    # custom_params = bank_account_params.merge({ stripe_token: params[:stripeToken], credit_card: params[:creditCard], exp_month: params[:expMonth], exp_year: params[:expYear], cvc: params[:cvc] })

    @bank_account = current_user.build_bank_account(bank_account_params)

    if @bank_account.save
      redirect_to profile_url, notice: 'Savings plan was successfully created.'
    else
      render :edit
    end
  end

  def update_bank_account
    # custom_params = bank_account_params.merge({ card_number: params[:card_number] })
    @bank_account = current_user.bank_account

    if @bank_account.update_attributes(bank_account_params)
      redirect_to profile_url, notice: 'Savings plan was successfully updated.'
    else
      puts @bank_account.errors[:authorize_net_error]
      render :edit
    end
  end

  def unsubscript
    current_user.bank_account.destroy
    current_user.update(total_credit: 0)
    redirect_to profile_url, notice: 'Bank account was successfully destroyed.'
  end

  private
    def set_profile
      if params[:id]
        @user = User.find params[:id]
      else
        @user = current_user
      end

      unless @user.profile
        redirect_to edit_profile_path, alert: "You haven't entered your profile. \n
          Please fill information below"
      end
    end

    def user_params
      params.require(:user).permit(profile_attributes: [:id, :first_name, :last_name, :birth_date, :gender, :address,
        :home_airport, :place_to_visit, :address_1, :address_2, :city, :state, :postal_code, :country_code,
        :image, :image_cache])
    end

    def bank_account_params
      params.require(:bank_account).permit(:id, :bank_name, :account_number, :routing_number, :amount_transfer, :transfer_frequency, :credit_card, :cvc, :exp_month, :exp_year)
    end
end
