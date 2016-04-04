class PaymentsController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:authorize_net_webhook]
  skip_before_action :authenticate, only: :authorize_net_webhook
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

  def authorize_net_webhook
    response = request.parameters

    if response['x_subscription_id'] && response['x_response_code'].eql?('1')
      PaymentProcessorMailer.send_request_params_webhook(response).deliver_now
      
      customer = Customer.find_by(customer_id: response['x_cust_id'])
      user_id = customer.user_id if customer

      transaction = Transaction.new(
        user_id: user_id,
        invoice_id: response['x_invoice_num'],
        amount: response['x_amount'].to_f * 100,
        customer_id: response['x_cust_id'],
        transaction_type: 'recurring_billing',    
        trans_id: response['x_trans_id']
      )

      if transaction.save
        # user = User.find(transaction.user_id)
        # user.total_credit += transaction.amount
        # user.save

        PaymentProcessorMailer.subscription_charged(user.id, transaction.amount).deliver_now
        
        # user.create_activity key: "payment.recurring", owner: user,
        #   recipient: user, parameters: { amount: (transaction.amount / 100.0), total_credit: user.total_credit / 100.0 }
      end
    end

    render nothing: true, status: 200
  end

end

