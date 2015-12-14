class PaymentsController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:stripe_webhook]
  before_action :authenticate_user!, only: [:create, :thank_you_page]

  def create
    if !params[:payment][:amount].empty?
      begin
        amount_to_cents    = params[:payment][:amount].to_f * 100

        charge = Stripe::Charge.create(
          amount: amount_to_cents.to_i, # amount in cents, again
          currency: "usd",
          source: params[:stripeToken],
          description: "Manual payment"
        )

        if charge.paid
          transaction = current_user.transactions.new(amount: charge.amount, transaction_type: 'deposit')

          if transaction.save
            user = User.find current_user.id
            user.total_credit += charge.amount.to_i
            user.save

            StripeMailer.payment_succeed(current_user.id, transaction.amount, charge.source.last4).deliver_now
            redirect_to payments_thank_you_page_path(charge_id: charge.id)
          else
            redirect_to payments_path, alert: 'Some errors occured'
          end
        else
          redirect_to payments_path, alert: 'Some errors occured'
        end
      rescue Stripe::CardError => e
        redirect_to payments_path, alert: e.message
      end
    else
      redirect_to payments_path, alert: "Amount can't be blank"
    end
  end

  def thank_you_page
    @charge = Stripe::Charge.retrieve(params[:charge_id])
  end

  def stripe_webhook
    response = JSON.parse(request.body.read)

    if response['type'].eql?('invoice.payment_succeeded') && response['data']['object']['amount_due'] > 0
      response = response['data']['object']

      transaction = Transaction.new(
        user_id: response['lines']['data'].last['metadata']['user_id'],
        invoice_id: response['id'],
        amount: response['amount_due'],
        customer_id: response['customer'],
        transaction_type: 'deposit'
      )

      if transaction.save
        user = User.find(transaction.user_id)
        user.total_credit += transaction.amount
        user.save

        StripeMailer.subscription_charged(user.id, transaction.amount).deliver_now
        user.create_activity key: "payment.recurring", owner: user,
          recipient: user, parameters: { amount: (transaction.amount / 100.0), total_credit: user.total_credit / 100.0 }
      end

    end

    render nothing: true, status: 200
  end
end
