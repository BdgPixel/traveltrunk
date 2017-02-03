# == Schema Information
#
# Table name: bank_accounts
#
#  id                 :integer          not null, primary key
#  bank_name          :string
#  account_number     :string
#  routing_number     :string
#  amount_transfer    :decimal(, )
#  transfer_frequency :string
#  user_id            :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class BankAccount < ActiveRecord::Base
  include ExceptionErrorResponse

  belongs_to :user

  before_create :create_subscription
  before_update :update_subscription
  before_destroy :unsubscriptions
  after_create :send_savings_plan_created_email
  after_update :send_savings_plan_updated_email

  attr_accessor :exp_month, :exp_year, :card_number, :stripe_token, :credit_card, :cvc

  validates :amount_transfer, presence: true
  validates :transfer_frequency, presence: { message: 'please select one' }
  validates :amount_transfer, numericality: { only_integer: false }
  validate :validate_amount
  # validate :auth_credit_card

  def validate_amount
    if self.amount_transfer.to_f < 25.0
      self.errors.add(:amount_transfer, 'Amount transfer must be greater than or equal to $25.00')
    end
  end

  def auth_credit_card
    payment_transaction = AuthorizeNetLib::PaymentTransactions.new

    begin
      response = payment_transaction.auth_credit_card(self.user.profile, self.credit_card,
        self.cvc, self.exp_card)
      
      unless response.messages.resultCode.eql? AuthorizeNet::API::MessageTypeEnum::Ok
        self.errors.add(:authorize_net_error, response.messages.messages.first.text)
      end
    rescue => e
      if e.is_a?(AuthorizeNetLib::RescueErrorsResponse)
        self.errors.add(:authorize_net_error, e.error_message[:response_error_text])
      else
        logger.error e.message
        e.backtrace.each { |line| logger.error line }
      end
    end
  end

  def exp_card
    "#{self.exp_month.rjust(2, '0')}#{self.exp_year[-2, 2]}"
  end

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
    customer = Customer.where(user_id: self.user_id).first
    subscription = Subscription.where(user_id: self.user_id).first

    params_recurring = get_recurring_params
    
    params_recurring[:customer][:customer_id] = 
      if customer
        customer.customer_id
      else
        AuthorizeNetLib::Global.generate_random_id('cus')
      end

    begin
      recurring_authorize = AuthorizeNetLib::RecurringBilling.new

      start_date = Time.now.in_time_zone("Pacific Time (US & Canada)").strftime("%Y-%m-%d")
      params_recurring[:customer][:start_date] = start_date
      response = recurring_authorize.create_subscription(params_recurring)

      if response.messages.resultCode.eql? 'Ok'
        unless customer
          Customer.create(customer_id: params_recurring[:customer][:customer_id], user_id: user.id, customer_profile_id: response.profile.customerProfileId)
        end

        subscription_params = 
          {
            subscription_id: response.subscriptionId,
            amount: params_recurring[:plan][:amount] * 100,
            interval: params_recurring[:plan][:interval_unit],
            interval_count: params_recurring[:plan][:interval_length],
            plan_name: params_recurring[:plan][:plan_name],
            user_id: user.id
          }

        if subscription
          subscription.update_attributes(subscription_params)
        else
          Subscription.create(subscription_params)
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

  def update_subscription
    customer = Customer.where(user_id: self.user_id).first
    user_subscription = user.subscription

    params_recurring = get_recurring_params

    begin
      customer_authorize = AuthorizeNetLib::Customers.new
      customer_profile = customer_authorize.get_customer_profile(customer.customer_profile_id)
      customer_payment_profile = customer_profile.paymentProfiles.first
      recurring_authorize = AuthorizeNetLib::RecurringBilling.new

      customer_credit_card_last_4 = customer_payment_profile.payment.creditCard.cardNumber.last(4) rescue nil
      credit_card_changed = customer_credit_card_last_4 != self.credit_card.try(:last, 4)

      if user_subscription
        if credit_card_changed || self.changed.include?('amount_transfer') || self.changed.include?('transfer_frequency')
          selected_params = params_recurring.select { |k, v| [:subscription_id, :plan].include?(k) }
          subscription_hash = user_subscription.get_params_hash(selected_params)
          
          start_date = Time.now.in_time_zone("Pacific Time (US & Canada)")
          start_date = (start_date + eval("#{params_recurring[:plan][:interval_length]}.#{params_recurring[:plan][:interval_unit]}")).strftime("%Y-%m-%d")
          params_recurring[:customer][:customer_id] = customer.customer_id
          params_recurring[:plan][:start_date] = start_date
          subscription_response = recurring_authorize.create_subscription(params_recurring)

          subscription_hash.merge!(subscription_id: subscription_response.subscriptionId)
          user_subscription.update(subscription_hash)
          
          if customer_payment_profile
            AuthorizeNetLib::RecurringBilling.delay.cancel_other_subscriptions(user_subscription.subscription_id, customer_profile.customerProfileId)
          end
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
    plan_name = "#{user.profile_first_name.titleize} #{self.transfer_frequency} Savings Plan"

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

  def unsubscriptions
    if self.user
      begin
        customer_authorize = AuthorizeNetLib::Customers.new
        recurring_authorize = AuthorizeNetLib::RecurringBilling.new

        get_customer = customer_authorize.get_customer_profile(self.user.customer.customer_profile_id)
        customer_profile_id = get_customer.customerProfileId
        payment_profile_id = get_customer.paymentProfiles.first.customerPaymentProfileId

        subscription_id = self.user.subscription.subscription_id

        Subscription.where(user_id: self.user_id).destroy_all

        PaymentProcessorMailer.delay.cancel_subscription(self.user.id)

        user.create_activity key: 'payment.unsubscription', owner: self.user, recipient: self.user
        
        AuthorizeNetLib::RecurringBilling.delay.cancel_other_subscriptions(nil, customer_profile_id)
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
          false
        else
          logger.error e.message
          e.backtrace.each { |line| logger.error line }
        end

      end
    end
  end

  def send_savings_plan_created_email
    PaymentProcessorMailer.delay.subscription_created(self.user_id)
  end

  def send_savings_plan_updated_email
    PaymentProcessorMailer.delay.subscription_updated(self.user_id)
  end
end
