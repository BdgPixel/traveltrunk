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

    customer = Customer.find_by(customer_id: response['x_cust_id'])
    user, customer_profile_id = [customer.user, customer.customer_profile_id] if customer

    PaymentProcessorMailer.send_request_params_webhook(response).deliver_now

    if response['x_subscription_id'] 
      if response['x_response_code'].eql?('1')
        transaction = Transaction.new(
          user_id: user.id,
          invoice_id: response['x_invoice_num'],
          amount: response['x_amount'].to_f * 100,
          transaction_type: 'payment.recurring',
          trans_id: response['x_trans_id']
        )

        PaymentProcessorMailer.subscription_charged(user.id, transaction.amount).deliver_now if transaction.save
      else
        recurring_authorize = AuthorizeNetLib::RecurringBilling.new
        subscription_status = recurring_authorize.get_subscription_status(response['x_subscription_id'])

        if ['suspended', 'cancelled', 'terminated'].include? subscription_status
          begin
            recurring_authorize.cancel_subscription(response['x_subscription_id'], customer_profile_id)
            
            user.create_activity(
              key: 'payment.subscription_failed', 
              owner: user, 
              recipient: user,
              parameters: {
                subscription_id: response['x_subscription_id'],
                subscription_status: subscription_status,
                subscription_message: response['x_response_reason_text']
              }
            )

            Subscription.where(user_id: user.id, subscription_id: response['x_subscription_id']).destroy_all
            # Customer.where(user_id: user.id).destroy_all
            Bank_account.where(user_id: user.id).delete_all

            PaymentProcessorMailer.subscription_failed(user.id, response['x_subscription_id'], subscription_status, response['x_response_reason_text']).deliver_now
          rescue => e
            logger.error e.message
          end
        end
      end
    end

    render nothing: true, status: 200
  end

  def get_authorize_net_webhook
    response = request.parameters
    PaymentProcessorMailer.send_request_params_webhook(response).deliver_now
    
    render nothing: true, status: 200
  end

  def self.scheduler
    begin
      transaction_reporting_authorize = AuthorizeNetLib::TransactionReporting.new
      batch_list = transaction_reporting_authorize.get_settled_batch_list
      
      if batch_list
        batch_list.each do |batch|
          transaction_authorize_list = transaction_reporting_authorize.get_transaction_list(batch.batchId)

          transaction_authorize_list.each do |trans_authoirze|
            transaction_detail = transaction_reporting_authorize.get_transaction_details(trans_authoirze.transId)
            customer = Customer.find_by(customer_id: transaction_detail.transaction.customer.id)
            user = customer.user if customer
            
            if ['settledSuccessfully'].include? trans_authoirze.transactionStatus
              unless Transaction.where(trans_id: trans_authoirze.transId).exists?
                transaction = Transaction.new(
                  user_id: user.id,
                  invoice_id: trans_authoirze.invoiceNumber,
                  amount: trans_authoirze.settleAmount.to_f * 100,
                  trans_id: trans_authoirze.transId,
                  transaction_type: 'payment.recurring'
                )

                PaymentProcessorMailer.subscription_charged(user.id, transaction.amount).deliver_now if transaction.save
              end
            elsif ['communicationError', 'declined', 'generalError', 'settlementError'].include? trans_authoirze.transactionStatus
              recurring_authorize = AuthorizeNetLib::RecurringBilling.new
              subscription_status = recurring_authorize.get_subscription_status(trans_authoirze.subscription)

              user.create_activity(
                key: 'payment.subscription_failed', 
                owner: user, 
                recipient: user,
                parameters: {
                  subscription_id: trans_authoirze.subscription,
                  subscription_status: trans_authoirze.transactionStatus,
                  subscription_message: nil
                }
              )

              Subscription.where(user_id: user.id, subscription_id: trans_authoirze.subscription).destroy_all
              Bank_account.where(user_id: user.id).delete_all

              PaymentProcessorMailer.subscription_failed(user.id, trans_authoirze.subscription, trans_authoirze.transactionStatus).deliver_now
            end
          end
        end
      end
    rescue => e
      logger.error e.message
    end
  end
end

