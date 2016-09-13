class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profile, only: [:show]

  def show
    @hide_informations = false

    if params[:id]
      @hide_informations = true
    end
  end

  def edit
    current_user.build_profile unless current_user.profile
    @bank_account = current_user.bank_account || current_user.build_bank_account
  end

  def update
    @bank_account = current_user.bank_account || current_user.build_bank_account

    current_user.profile.validate_personal_information = true

    respond_to do |format|
      if current_user.update_attributes(user_params)
        if current_user.bank_account.new_record?
          format.html { redirect_to edit_profile_url(anchor: 'bank_account'),
            notice: 'Profile was successfully updated.' }
          format.js
        else
          format.html { redirect_to profile_url, alert: 'Profile was unsuccessfully updated.' }
          format.js
        end
      else
        format.html { render :edit }
        format.js
      end
    end
  end

  def create_bank_account
    @bank_account = current_user.build_bank_account(bank_account_params)

    respond_to do |format|
      if @bank_account.save
        format.html { redirect_to profile_url, notice: 'Savings plan was successfully created.' }
        format.js
      else
        @error_card_number =  @bank_account.errors[:authorize_net_error].first.split(' (6) ').join(' ')
        @wew = 'asdf (6)'.html_safe
        puts @bank_account.errors[:authorize_net_error]
        format.html { render :edit }
        format.js
      end
    end
  end

  def update_bank_account
    @bank_account = current_user.bank_account

    respond_to do |format|
      if @bank_account.update_attributes(bank_account_params)
        format.html { redirect_to profile_url, notice: 'Savings plan was successfully updated.' }
        format.js
      else
        @error_card_number =  @bank_account.errors[:authorize_net_error].first.split(' (6) ').join(' ')
        puts @bank_account.errors[:authorize_net_error]
        format.html { render :edit }
        format.js
      end
    end
  end

  def unsubscript
    if current_user.bank_account.destroy
      redirect_to profile_url, notice: 'Savings plan was successfully deleted.'
    else
      redirect_to profile_url, notice: 'Some errors occurred when try deleting your savings plan.'
    end
  end

  private
    def set_profile
      @user = 
        if params[:id]
          User.find params[:id]
        else
          current_user
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
