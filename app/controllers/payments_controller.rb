class PaymentsController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:stripe_webhook]

  def index
  end

  def create
    token              = params[:stripeToken]
    api_key            = 'sk_test_ZqnJoRfoLZjcJQzgBjmqpJGy'
    amount_to_cents    = current_user.bank_account.amount_transfer.to_f * 100
    transfer_interval  = current_user.bank_account.transfer_type

    # customer = current_user.set_stripe_customer(api_key, token)
    # plan     = current_user.set_stripe_plan(api_key, transfer_interval)
    yuhuu
    # customer.subscriptions.create(plan: plan.id)

      # charge = Stripe::Charge.create(
      #   :amount => amount_to_cents.to_i, # amount in cents, again
      #   :currency => "usd",
      #   customer: customer.id
      #   :source => token,
      #   :description => "Example charge"
      # )
  end

  def stripe_webhook
    response = JSON.parse(request.body.read)

    if response["type"].eql? "invoice.payment_succeeded"
      response = response["data"]["object"]

      transaction = Transaction.new(
        user_id: response["lines"]["data"].first["metadata"]["user_id"],
        invoice_id: response["id"],
        amount: response["amount_due"],
        customer_id: response["customer"],
        transaction_type: "deposit"
      )

      if transaction.save
        user = User.find(transaction.user_id)
        user.total_credit += transaction.amount
        user.save
      end
    end
    render nothing: true, status: 200
    # status 200
  end
end
