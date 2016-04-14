class BankAccount < ActiveRecord::Base
  include ExceptionErrorResponse

  belongs_to :user

  before_create :create_subscription
  before_update :update_subscription
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

  def create_subscription
    customer_id = AuthorizeNetLib::Global.generate_random_id('cus')
    params_recurring = get_recurring_params

    begin
      # params_recurring = {
      #   ref_id: AuthorizeNetLib::Global.generate_random_id('ref'),
      #   card: {
      #     credit_card: self.credit_card,
      #     cvc: self.cvc,
      #     exp_card: "#{self.exp_month.rjust(2, '0')}#{self.exp_year[-2, 2]}",
      #   },
      #   plan: {
      #     interval_unit: interval_frequency,
      #     interval_length: interval_count,
      #     trial_occurrences: '0',
      #     amount: amount,
      #     plan_name: plan_name,
      #     start_date: Time.now.in_time_zone("Pacific Time (US & Canada)").strftime("%Y-%m-%d")
      #   },
      #   customer: {
      #     customer_id: customer_id,
      #     first_name: user.profile.first_name,
      #     last_name: user.profile.last_name,
      #     email: user.email,
      #     company: nil,
      #     address: user.profile.address,
      #     city: user.profile.city,
      #     state: user.profile.state,
      #     zip: user.profile.postal_code,
      #     country: user.profile.country_code,
      #   },
      #   order: {
      #     invoice_number: AuthorizeNetLib::Global.generate_random_id('inv') 
      #   },
      # }

      recurring_authorize = AuthorizeNetLib::RecurringBilling.new

      params_recurring[:customer][:customer_id] = customer_id
      start_date = Time.now.in_time_zone("Pacific Time (US & Canada)").strftime("%Y-%m-%d")
      params_recurring[:customer][:start_date] = start_date
      response = recurring_authorize.create_subscription(params_recurring)
      
      if response.messages.resultCode.eql? 'Ok'
        Customer.create(customer_id: customer_id, user_id: user.id, customer_profile_id: response.profile.customerProfileId)

        Subscription.create({
          subscription_id: response.subscriptionId,
          amount: params_recurring[:plan][:amount] * 100,
          interval: params_recurring[:plan][:interval_unit],
          interval_count: params_recurring[:plan][:interval_length],
          plan_name: params_recurring[:plan][:plan_name],
          user_id: user.id
        })
      end
    rescue => e
      logger.error e

      if e.is_a?(AuthorizeNetLib::RescueErrorsResponse)
        @error_response = 
          if e.error_message[:response_error_text]
            "#{e.error_message[:response_message]} #{response_error_code}"
          else
            e.error_message[:response_message].split('-').last.strip
          end

        self.errors.add(:authorize_net_error, @error_response)
      else
        logger.error e.message
        e.backtrace.each { |line| logger.error line }
      end

      false
    end
  end

  def update_subscription 
    customer = Customer.where(user_id: self.user_id).first
    user_subscription = user.subscription

    params_recurring = get_recurring_params

    begin
      # params_recurring = {
      #   ref_id: AuthorizeNetLib::Global.generate_random_id('ref'),
      #   card: {
      #     credit_card: self.credit_card,
      #     cvc: self.cvc,
      #     exp_card: "#{self.exp_month.rjust(2, '0')}#{self.exp_year[-2, 2]}",
      #   },
      #   plan: {
      #     interval_unit: interval_frequency,
      #     interval_length: interval_count,
      #     trial_occurrences: '0',
      #     amount: amount,
      #     plan_name: plan_name
      #   },
      #   customer: {
      #     customer_id: customer.customer_id,
      #     first_name: user.profile.first_name,
      #     last_name: user.profile.last_name,
      #     email: user.email,
      #     company: nil,
      #     address: user.profile.address,
      #     city: user.profile.city,
      #     state: user.profile.state,
      #     zip: user.profile.postal_code,
      #     country: user.profile.country_code,
      #   },
      #   order: {
      #     invoice_number: AuthorizeNetLib::Global.generate_random_id('inv') 
      #   },
      # }

      customer_authorize = AuthorizeNetLib::Customers.new
      puts customer.customer_profile_id
      customer_profile = customer_authorize.get_customer_profile(customer.customer_profile_id)
      customer_payment_profile = customer_profile.paymentProfiles.first
      recurring_authorize = AuthorizeNetLib::RecurringBilling.new

      customer_credit_card_last_4 = customer_payment_profile.payment.creditCard.cardNumber.last(4) rescue nil
      credit_card_changed = customer_credit_card_last_4 != self.credit_card.last(4)

      if user_subscription
        if credit_card_changed || self.changed.include?('amount_transfer') || self.changed.include?('transfer_frequency')
          if customer_payment_profile
            response = recurring_authorize.cancel_subscription(user_subscription.subscription_id, customer_profile.customerProfileId, customer_payment_profile.customerPaymentProfileId)
            response.messages.resultCode
          end

          selected_params = params_recurring.select { |k, v| [:subscription_id, :plan].include?(k) }
          subscription_hash = user_subscription.get_params_hash(selected_params)
          
          start_date = Time.now.in_time_zone("Pacific Time (US & Canada)")
          start_date = (start_date + eval("#{params_recurring[:plan][:interval_length]}.#{params_recurring[:plan][:interval_unit]}")).strftime("%Y-%m-%d")
          params_recurring[:customer][:customer_id] = customer.customer_id
          params_recurring[:plan][:start_date] = start_date
          subscription_response = recurring_authorize.create_subscription(params_recurring)

          subscription_hash.merge!(subscription_id: subscription_response.subscriptionId)
          user_subscription.update(subscription_hash)
        end 
      end
    rescue => e
      logger.error e

      if e.is_a?(AuthorizeNetLib::RescueErrorsResponse)
        @error_response = 
          if e.error_message[:response_error_text]
            "#{e.error_message[:response_message]} #{response_error_code}"
          else
            e.error_message[:response_message].split('-').last.strip
          end

        self.errors.add(:authorize_net_error, @error_response)
      else
        logger.error e.message
        e.backtrace.each { |line| logger.error line }
      end

      false
    end
  end

  def get_recurring_params
    profile = self.user.profile

    amount = self.amount_transfer.to_f
    interval_frequency, interval_count = self.transfer_type
    plan_name = "#{user.profile.first_name.titleize} #{self.transfer_frequency} Savings Plan"

    {
      ref_id: AuthorizeNetLib::Global.generate_random_id('ref'),
      card: {
        credit_card: self.credit_card,
        cvc: self.cvc,
        exp_card: "#{self.exp_month.rjust(2, '0')}#{self.exp_year[-2, 2]}",
      },
      plan: {
        interval_unit: interval_frequency,
        interval_length: interval_count,
        trial_occurrences: '0',
        amount: amount,
        plan_name: plan_name,
        start_date: Time.now.in_time_zone("Pacific Time (US & Canada)").strftime("%Y-%m-%d")
      },
      customer: {
        # customer_id: customer_id,
        first_name: profile.first_name,
        last_name: profile.last_name,
        email: self.user.email,
        company: nil,
        address: profile.address,
        city: profile.city,
        state: profile.state,
        zip: profile.postal_code,
        country: profile.country_code,
      },
      order: {
        invoice_number: AuthorizeNetLib::Global.generate_random_id('inv') 
      },
    }
  end

=begin
  def set_customer_profile
    user = self.user

    if user
      unless user.customer
        begin
          customer_from_authorize_net = AuthorizeNetLib::Customers.new
          merchant_customer_id = AuthorizeNetLib::Global.generate_random_id('cus')

          response = customer_from_authorize_net.create_profile({ 
            merchant_customer_id: merchant_customer_id, 
            email: self.user.email 
          })

          if response.messages.resultCode.eql? 'Ok'
            @customer_id = response.customerProfileId
            Customer.create(customer_id: merchant_customer_id, user_id: user.id, customer_profile_id: response.customerProfileId)
          end
        rescue => e
          logger.error e.message

          self.errors.add(:authorize_net_error, e.error_message[:response_message])
          false
        end
      end
    end
  end

  def set_recurring_subscription
    user = self.user
    
    if user
      customer = Customer.where(user_id: user).first

      user_subscription = user.subscription
      amount = self.amount_transfer.to_f
      interval_frequency, interval_count = self.transfer_type
      plan_name = "#{user.profile.first_name.titleize} #{self.transfer_frequency} Savings Plan"

      begin
        params_recurring = {
          ref_id: AuthorizeNetLib::Global.generate_random_id('ref'),
          card: {
            credit_card: self.credit_card,
            cvc: self.cvc,
            exp_card: "#{self.exp_month.rjust(2, '0')}#{self.exp_year[-2, 2]}",
          },
          plan: {
            interval_unit: interval_frequency,
            interval_length: interval_count,
            trial_occurrences: '0',
            amount: amount,
            plan_name: plan_name
          },
          customer: {
            customer_id: customer.customer_id,
            first_name: user.profile.first_name,
            last_name: user.profile.last_name,
            email: user.email,
            company: nil,
            address: user.profile.address,
            city: user.profile.city,
            state: user.profile.state,
            zip: user.profile.postal_code,
            country: user.profile.country_code,
          },
          order: {
            invoice_number: AuthorizeNetLib::Global.generate_random_id('inv') 
          },
        }
        
        customer_authorize = AuthorizeNetLib::Customers.new
        customer_profile = customer_authorize.get_customer_profile(customer.customer_profile_id)
        customer_payment_profile = customer_profile.paymentProfiles.first

        recurring_authorize = AuthorizeNetLib::RecurringBilling.new
        start_date = Time.now.in_time_zone("Pacific Time (US & Canada)")

        if user_subscription
          customer_credit_card_last_4 = customer_payment_profile.payment.creditCard.cardNumber.last(4) rescue nil
          credit_card_changed = customer_credit_card_last_4 != self.credit_card.last(4)
        
          if credit_card_changed || self.changed.include?('amount_transfer') || self.changed.include?('transfer_frequency')
            if customer_payment_profile
              response = recurring_authorize.cancel_subscription(user_subscription.subscription_id, customer_profile.customerProfileId, customer_payment_profile.customerPaymentProfileId)
              response.messages.resultCode
            end

            selected_params = params_recurring.select { |k, v| [:subscription_id, :plan].include?(k) }
            subscription_hash = user_subscription.get_params_hash(selected_params)
            
            start_date = (start_date + eval("#{interval_count}.#{interval_frequency}")).strftime("%Y-%m-%d")
            params_recurring[:plan][:start_date] = start_date
            subscription_response = recurring_authorize.create_subscription(params_recurring)

            subscription_hash.merge!(subscription_id: subscription_response.subscriptionId)
            user_subscription.update(subscription_hash)
          end 
        else
          # create subscription
          params_recurring[:plan][:start_date] = start_date.strftime("%Y-%m-%d")
          response = recurring_authorize.create_subscription(params_recurring)

          if response.messages.resultCode.eql? 'Ok'
            Subscription.create({
              subscription_id: response.subscriptionId,
              amount: amount * 100,
              interval: interval_frequency,
              interval_count: interval_count,
              plan_name: plan_name,
              user_id: user.id
            })
          else
            puts user.customer.inspect
          end
        end
      rescue => e
        logger.error @customer_id

        if e.is_a?(AuthorizeNetLib::RescueErrorsResponse)
          @error_response = 
            if e.error_message[:response_error_text]
              "#{e.error_message[:response_message]} #{response_error_code}"
            else
              e.error_message[:response_message].split('-').last.strip
            end
            
          if e.error_message[:response_error_code].eql? 'E00040'
            customer_authorize = AuthorizeNetLib::Customers.new
            customer_authorize.delete_customer_profile(@customer_id)
          end

          self.errors.add(:authorize_net_error, @error_response)
          false
        else
          logger.error e.message
          e.backtrace.each { |line| logger.error line }
        end
      end
    end
  end
=end

  def unsubscriptions
    if self.user
      begin
        customer_authorize = AuthorizeNetLib::Customers.new
        recurring_authorize = AuthorizeNetLib::RecurringBilling.new

        get_customer = customer_authorize.get_customer_profile(self.user.customer.customer_profile_id)
        customer_profile_id = get_customer.customerProfileId
        payment_profile_id = get_customer.paymentProfiles.first.customerPaymentProfileId

        subscription_id = self.user.subscription.subscription_id
        cancel_subscription = recurring_authorize.cancel_subscription(subscription_id, customer_profile_id, payment_profile_id)

        customer_authorize.delete_customer_profile(customer_profile_id)
        Subscription.where(user_id: self.user_id).destroy_all
        Customer.where(user_id: self.user_id).destroy_all

        PaymentProcessorMailer.cancel_subscription(self.user.id).deliver_now
        user.create_activity key: 'payment.unsubscription', owner: self.user, recipient: self.user
      rescue => e
        logger.error e.message
        
        if e.is_a?(AuthorizeNetLib::RescueErrorsResponse)
          @error_response = 
            if e.error_message[:response_error_text]
              "#{e.error_message[:response_message]} #{e.error_message[:response_error_text]}"
            else
              e.error_message[:response_message].split('-').last.strip
            end
            
          self.errors.add(:authorize_net_error, @error_response)
          # false
        else
          logger.error e.message
          e.backtrace.each { |line| logger.error line }
        end

      end
    end
  end
end
