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
        token              = params[:stripeToken]
        api_key            = 'sk_test_ZqnJoRfoLZjcJQzgBjmqpJGy'
        amount_to_cents    = current_user.bank_account.amount_transfer.to_f * 100

        interval_frequency, interval_count = current_user.bank_account.transfer_type

        customer = current_user.set_stripe_customer(api_key, token)
        plan     = current_user.set_stripe_plan(api_key, interval_frequency, interval_count)

        customer.subscriptions.create(plan: plan.id, metadata: { user_id: current_user.id })
        # yuhuu
        Subscription.create(
          plan_id:        plan.id,
          amount:         plan.amount,
          currency:       plan.currency,
          interval:       plan.interval,
          interval_count: plan.interval_count,
          plan_name:      plan.name
        )

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
      params.require(:user).permit(profile_attributes: [:id, :first_name, :last_name, :birth_date, :gender, :address,
        :address_1, :address_2, :city, :state, :postal_code, :country_code, :image, :image_cache],
        bank_account_attributes: [:id, :bank_name, :account_number, :routing_number, :amount_transfer, :transfer_frequency]
        )
    end
end
