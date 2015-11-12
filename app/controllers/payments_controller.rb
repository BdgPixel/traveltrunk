class PaymentsController < ApplicationController
  def index
  end

  def create
    token              = params[:stripeToken]
    api_key            = 'sk_test_ZqnJoRfoLZjcJQzgBjmqpJGy'
    amount_to_cents    = current_user.bank_account.amount_transfer.to_f * 100
    transfer_interval  = current_user.bank_account.transfer_type

    customer = current_user.set_stripe_customer(api_key, token)
    plan     = current_user.set_stripe_plan(api_key, transfer_interval)
    # yuhuu
    customer.subscriptions.create(plan: plan.id)

      # charge = Stripe::Charge.create(
      #   :amount => amount_to_cents.to_i, # amount in cents, again
      #   :currency => "usd",
      #   customer: customer.id
      #   :source => token,
      #   :description => "Example charge"
      # )
  end
end
