class PaymentProcessorMailer < ApplicationMailer
  helper SavingsHelper

  def subscription_created(user_id)
    user = User.select(:id, :email).find user_id

    @profile = user.profile
    @subscription = user.subscription

    mail to: user.email, subject: 'Your new saving plan'
  end

  def subscription_updated(user_id)
    user = User.select(:id, :email).find user_id

    @profile = user.profile
    @subscription = user.subscription

    mail to: user.email, subject: 'Your new saving plan'
  end

  def subscription_charged(user_id, amount)
    @user = User.select(:id, :email, :total_credit).find user_id

    @profile = @user.profile
    @subscription = @user.subscription
    @amount = amount

    # mail to: @user.email, subject: 'Reoccurring Payment'
    mail to: 'teguh@41studio.com', subject: 'Reoccurring Payment'
  end

  def payment_succeed(user_id, amount, card_last4)
    @user = User.select(:id, :email, :total_credit).find user_id

    @profile = @user.profile
    @subscription = @user.subscription
    @amount = amount
    @card_last4 = card_last4

    mail to: @user.email, subject: 'One time Payment Successful'
  end

  def cancel_subscription(user_id)
    user = User.select(:id, :email, :total_credit).find user_id

    @profile = user.profile
    mail to: user.email, subject: 'Subscription Canceled'
  end

  def subscription_failed(user_id, subscription_id, subscription_status, subscription_message = nil)
    user = User.select(:id, :email, :total_credit).find user_id

    @profile = user.profile
    @subscription_status = subscription_status
    @subscription_id = subscription_id
    @subscription_message = subscription_message

    # mail to: user.email, subject: "Payment #{subscription_status.titleize}"
    mail to: 'teguh@41studio.com', subject: "Payment #{subscription_status.titleize}"
  end

  def send_request_params_webhook(params)
    @response_params = params
    
    mail to: 'teguh@41studio.com', subject: 'Params webhook'
  end

  def refund_approved(refund, transaction_type)
    @refund = refund
    @transaction_type = transaction_type
    mail to: @refund.user.email, subject: 'Refund Successfully Approved'
  end
end
