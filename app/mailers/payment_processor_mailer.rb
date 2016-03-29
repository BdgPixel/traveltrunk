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

    mail to: @user.email, subject: 'Reoccurring Payment'
  end

  def payment_succeed(user_id, amount, card_last4)
    @user = User.select(:id, :email, :total_credit).find user_id

    @profile = @user.profile
    @subscription = @user.subscription
    @amount = amount
    @card_last4 = card_last4

    # group = @user.group || @user.joined_groups.first
    # @total_credit = 
    #   if group
    #     if group.members.any?
    #       group.total_credit
    #     else
    #       @user.total_credit
    #     end
    #   else
    #     @user.total_credit
    #   end

    mail to: @user.email, subject: 'One time Payment Successful'
  end

  def cancel_subscription(user_id)
    user = User.select(:id, :email, :total_credit).find user_id

    @profile = user.profile
    mail to: user.email, subject: 'Payment Canceled'
  end

  def send_request_params_webhook(params)
    @response_params = params
    
    mail to: 'teguh@41studio.com', subject: 'Params webhook'
  end

  def approved(refund)
    @refund = refund
    
    mail to: @refund.user.email, subject: 'Refund Successfully Approved'
  end
end
