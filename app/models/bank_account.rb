class BankAccount < ActiveRecord::Base
  belongs_to :user

  # before_save :set_stripe_customer, :set_stripe_subscription
  before_save :set_customer_profile
  before_destroy :unsubscriptions

  attr_accessor :exp_month, :exp_year, :card_number, :stripe_token

  validates :amount_transfer, presence: true
  validates :transfer_frequency, presence: { message: 'please select one' }
  validates :amount_transfer, numericality: { only_integer: false, greater_than: 0.5 }

  def transfer_type
    case  transfer_frequency
    when "Daily"
      ["day", 1, 1]
    when "Weekly"
      ["week", 1, 7]
    when "Bi Weekly"
      ["week", 2, 14]
    else
      ["month", 1, 31]
    end
  end

  def set_customer_profile
    user = self.user
    if user
      begin
        customer_from_authorize_net = AuthorizeNetLib::Customers.new
        unless user.customer
          merchant_customer_id = AuthorizeNetLib::Global.genrate_random_id('cus')
          response = customer_from_authorize_net.create_profile({ merchant_customer_id: merchant_customer_id, email: self.user.email })
          Customer.create(customer_id: merchant_customer_id, user_id: user.id)
        end
      rescue Exception => e
        logger.error e.message
        self.errors.add(:authorize_net_error, e.error_message[:response_message])
        false
      end
    end
  end

=begin
  def set_stripe_customer
    user = self.user
    if user
      begin
        if user.customer
          stripe_customer = Stripe::Customer.retrieve(user.customer.customer_id)
          stripe_customer.source = self.stripe_token
          stripe_customer.save
        else
          stripe_customer = Stripe::Customer.create(
            email: user.email,
            source: self.stripe_token
          )

          Customer.create(customer_id: stripe_customer.id, user_id: user.id)
        end
      rescue Stripe::CardError => e
        logger.error e.message
      end
    end
  end

  def set_stripe_subscription
    user = self.user
    if user
      customer          = Customer.where(user_id: user.id).first
      user_subscription = user.subscription

      if user_subscription.nil? || self.changed.include?('amount_transfer') || self.changed.include?('transfer_frequency')
        interval_frequency, interval_count, trial_period_days = self.transfer_type
        amount_to_cents = (self.amount_transfer.to_f * 100).to_i
        plan_name       = "#{user.profile.first_name.titleize} #{self.transfer_frequency} Savings Plan"

        stripe_plan = Stripe::Plan.create(
          id:             SecureRandom.hex,
          currency:       'usd',
          name:           plan_name,
          amount:         amount_to_cents,
          interval:       interval_frequency,
          interval_count: interval_count,
          trial_period_days: user_subscription ? trial_period_days : nil
        )

        stripe_customer = Stripe::Customer.retrieve(customer.customer_id)

        if user_subscription
          previous_plan = Stripe::Plan.retrieve(user_subscription.plan_id) rescue nil

          if previous_plan
            puts "delet previous plan"
            stripe_customer.subscriptions.retrieve(user_subscription.subscription_id).delete
            previous_plan.delete
          end

          stripe_subscription = stripe_customer.subscriptions.create({ plan: stripe_plan.id, metadata: { user_id: user.id } })

          user_subscription.update_attributes({
            plan_id:          stripe_plan.id,
            amount:           stripe_plan.amount,
            interval:         stripe_plan.interval,
            interval_count:   stripe_plan.interval_count,
            subscription_id:  stripe_subscription.id,
            plan_name:        plan_name
          })

          StripeMailer.subscription_created(user.id).deliver_now
        else
          stripe_subscription = stripe_customer.subscriptions.create({ plan: stripe_plan.id, metadata: { user_id: user.id } })

          Subscription.create(
            plan_id:        stripe_plan.id,
            subscription_id: stripe_subscription.id,
            amount:         stripe_plan.amount,
            currency:       stripe_plan.currency,
            interval:       stripe_plan.interval,
            interval_count: stripe_plan.interval_count,
            plan_name:      stripe_plan.name,
            user_id: user.id
          )

          StripeMailer.subscription_created(user.id).deliver_now
        end
      end
    end
  end
=end

  def unsubscriptions
    if self.user
      begin
        customer = Stripe::Customer.retrieve(self.user.customer.customer_id)
        previous_plan = Stripe::Plan.retrieve(self.user.subscription.plan_id) rescue nil
        if previous_plan
          customer.subscriptions.retrieve(self.user.subscription.subscription_id).delete
          previous_plan.delete
        end

        self.user.subscription.destroy
        StripeMailer.cancel_subscription(self.user.id).deliver_now
        user.create_activity key: 'payment.unsubscription', owner: self.user, recipient: self.user
      rescue Stripe::CardError => e
        logger.error e.message
      end
    end
  end

end
