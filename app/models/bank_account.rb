class BankAccount < ActiveRecord::Base
  belongs_to :user

  # before_save :set_stripe_customer, :set_stripe_subscription
  before_save :set_customer_profile, :set_recurring_subscription
  before_destroy :unsubscriptions

  attr_accessor :exp_month, :exp_year, :card_number, :stripe_token, :credit_card, :cvc

  validates :amount_transfer, presence: true
  validates :transfer_frequency, presence: { message: 'please select one' }
  validates :amount_transfer, numericality: { only_integer: false, greater_than: 0.5 }

  def transfer_type
    case  transfer_frequency
    when "Weekly"
      ["days", 7]
    when "Bi Weekly"
      ["days", 14]
    else
      ["months", 1]
    end
  end

  def set_customer_profile
    user = self.user

    if user
      begin
        customer_from_authorize_net = AuthorizeNetLib::Customers.new
        unless user.customer
          merchant_customer_id = AuthorizeNetLib::Global.genrate_random_id('cus')
          response = customer_from_authorize_net.create_profile({ 
            merchant_customer_id: merchant_customer_id, 
            email: self.user.email 
          })

          if response.messages.resultCode.eql? 'Ok'
            Customer.create(customer_id: merchant_customer_id, user_id: user.id, customer_profile_id: response.customerProfileId)
          end
        end
      rescue Exception => e
        logger.error e.message
        self.errors.add(:authorize_net_error, e.error_message[:response_message])
        false
      end
    end
  end

  def set_recurring_subscription
    user = self.user
    
    if user
      customer = Customer.where(user_id: user.id).first
      customer_profile_id = customer.customer_profile_id

      user_subscription = user.subscription
      amount = self.amount_transfer.to_f
      interval_frequency, interval_count = self.transfer_type
      plan_name = "#{user.profile.first_name.titleize} #{self.transfer_frequency} Savings Plan"
      subscription_id = user_subscription.subscription_id if user_subscription

      recurring_authorize = AuthorizeNetLib::RecurringBilling.new
      customer_authorize = AuthorizeNetLib::Customers.new

      begin
        params_recurring = {
          subscription_id: subscription_id,
          ref_id: AuthorizeNetLib::Global.genrate_random_id('ref'),
          user_id: user.id,
          card: {
            credit_card: self.credit_card,
            cvc: self.cvc,
            exp_card: "#{self.exp_month.rjust(2, '0')}#{self.exp_year[-2, 2]}",
          },
          plan: {
            interval_unit: interval_frequency,
            interval_length: interval_count,
            star_date: (DateTime.now).to_s[0...10],
            total_occurrences: '9999',
            amount: amount.to_f,
            plan_name: plan_name
          },
          customer: {
            # name: "#{self.user.profile.first_name} #{self.user.profile.last_name}",
            customer_id: customer.customer_id,
            first_name: user.profile.first_name,
            last_name: user.profile.last_name,
            email: user.email,
            company: nil,
            address: user.profile.address,
            city: user.profile.city,
            state: user.profile.state,
            zip: user.profile.postal_code,
            country: user.profile.country_code
          },
          order: {
            invoice_number: AuthorizeNetLib::Global.genrate_random_id('inv'),
            description: 'descriptionTest'
          },
        }

        get_customer = customer_authorize.get_customer_profile(customer_profile_id)
        customer_profile_id = get_customer.profile.customerProfileId
        payment_profile_id = get_customer.profile.paymentProfiles.first.customerPaymentProfileId if user_subscription

        last_card_number = 
          if user_subscription
            if get_customer.profile.paymentProfiles.first.payment.creditCard.cardNumber[-4..-1].eql?(self.credit_card[-4..-1])
              true
            else
              false
            end
          end

        if user_subscription.nil? || self.changed.include?('amount_transfer') || self.changed.include?('transfer_frequency')
          if user_subscription
            if last_card_number
              update_subscription = recurring_authorize.update_subscription(subscription_id, params_recurring[:plan][:amount])

              if update_subscription.messages.resultCode.eql? 'Ok'
                selected_params = params_recurring.select { |k, v| [:subscription_id, :plan, :user_id].include?(k) }
                subscription_hash = user_subscription.params_hash(selected_params)
                user_subscription.update_attributes(subscription_hash)

              end
            else
              cancel_subscription = recurring_authorize.cancel_subscription(subscription_id, customer_profile_id, payment_profile_id)

              if cancel_subscription.messages.resultCode.eql? 'Ok'
                create_subscription = recurring_authorize.create_subscription(params_recurring)
                user_subscription.update(subscription_id: create_subscription.subscriptionId)
              end
            end

            StripeMailer.subscription_created(user.id).deliver_now
          else
            create_subscription = recurring_authorize.create_subscription(params_recurring)

            if create_subscription.messages.resultCode.eql? 'Ok'
              Subscription.create({
                subscription_id: create_subscription.subscriptionId,
                amount: amount * 100,
                interval: interval_frequency,
                interval_count: interval_count,
                plan_name: plan_name,
                user_id: user.id
              })
            end
            
            StripeMailer.subscription_created(user.id).deliver_now
          end
        else
          unless last_card_number
            cancel_subscription = recurring_authorize.cancel_subscription(subscription_id, customer_profile_id, payment_profile_id)

            if cancel_subscription.messages.resultCode.eql? 'Ok'
              create_subscription = recurring_authorize.create_subscription(params_recurring)
              user_subscription.update(subscription_id: create_subscription.subscriptionId)
            end
          end
        end

      rescue Exception => e
        logger.error e.message
        response_message = 
          if e.error_message[:response_error_code].eql?('E00003')
            e.message
          else
            e.error_message[:response_message]
          end

        self.errors.add(:authorize_net_error, response_message)
        false
      end
    end

  end

  # def unsubscriptions
  #   if self.user
  #     begin
  #       customer = 
  #     rescue Exception => e
        
  #     end
  #   end

  # end

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
=end

end
