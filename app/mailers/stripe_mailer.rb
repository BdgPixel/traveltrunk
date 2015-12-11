class StripeMailer < ApplicationMailer
  helper SavingsHelper

  def subscription_created(user_id)
    user = User.select(:id, :email).find user_id

    @profile = user.profile
    @subscription = user.subscription

    mail to: user.email, subject: 'TravelTrunk - Subscription Created'
  end

  def subscription_updated(user_id)
    user = User.select(:id, :email).find user_id

    @profile = user.profile
    @subscription = user.subscription

    mail to: user.email, subject: 'TravelTrunk - Subscription Updated'
  end

  def subscription_charged(user_id, amount)
    @user = User.select(:id, :email, :total_credit).find user_id

    @profile = @user.profile
    @subscription = @user.subscription
    @amount = amount

    mail to: @user.email, subject: 'TravelTrunk - Subscription Charged'
  end

  def payment_succeed(user_id, amount, card_last4)
    @user = User.select(:id, :email, :total_credit).find user_id

    @profile = @user.profile
    @subscription = @user.subscription
    @amount = amount
    @card_last4 = card_last4

    mail to: @user.email, subject: 'TravelTrunk - Payment Succeed'
  end
end
