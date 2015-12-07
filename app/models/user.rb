class User < ActiveRecord::Base
  include PublicActivity::Model

  has_one  :profile, dependent: :destroy
  has_one  :bank_account, dependent: :destroy
  has_many :likes

  has_one  :destination, dependent: :destroy
  has_many :joined_groups, -> { where("users_groups.accepted_at IS NOT NULL") } , through: :users_groups
  has_many :users_groups
  has_one  :group, dependent: :destroy
  has_one  :customer, dependent: :destroy
  has_one :subscription, dependent: :destroy
  has_many :transactions, dependent: :destroy
  has_many :reservations, dependent: :destroy

  accepts_nested_attributes_for :profile
  accepts_nested_attributes_for :bank_account

  before_save :set_stripe_customer, :set_stripe_subscription

  attr_accessor :stripe_token, :execute_stripe_callbacks

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable


  def no_profile?
    self.profile.nil? || self.profile.new_record?
  end

  def full_name
    "#{self.profile.first_name} #{self.profile.last_name}".titleize
  end

  def total_credit_in_usd
    (self.total_credit / 100).round
  end

  def get_notification(is_read = true)
    PublicActivity::Activity.order("created_at desc")
      .where(recipient_id: self.id, recipient_type: "User", is_read: is_read)
  end

  def get_current_destination
    if destination  = self.destination
      search_params = destination.get_search_params
    end
  end

  def expedia_room_params(hotel_id, rate_code = nil, room_type_code = nil)
    current_search = self.get_current_destination

    room_hash = {}

    room_hash[:hotelId]       = hotel_id
    room_hash[:arrivalDate]   = current_search[:arrivalDate]
    room_hash[:departureDate] = current_search[:departureDate]

    if rate_code && room_type_code
      room_hash[:rateCode]     = rate_code
      room_hash[:roomTypeCode] = room_type_code
    end

    room_hash[:RoomGroup]         = { Room: { numberOfAdults: 1 } }
    room_hash[:includeRoomImages] = true
    room_hash[:options]           = "ROOM_TYPES"
    room_hash[:includeDetails]    = true
    room_hash
  end

  def set_stripe_customer
    if self.execute_stripe_callbacks
      begin
        if self.customer
          puts "update customer"
          stripe_customer = Stripe::Customer.retrieve(self.customer.customer_id)
          stripe_customer.source = self.stripe_token
          stripe_customer.save
        else
          puts "create new customer"
          stripe_customer = Stripe::Customer.create(
            email: self.email,
            source: self.stripe_token
          )

          Customer.create(customer_id: stripe_customer.id, user_id: id)
        end
      rescue Stripe::CardError => e
        logger.error e.message
      end
    end
  end

  def set_stripe_subscription
    if self.execute_stripe_callbacks
      customer          = Customer.where(user_id: self.id).first
      user_bank_account = self.bank_account
      user_subscription = self.subscription

      if user_subscription.nil? || user_bank_account.changed.include?('amount_transfer') || user_bank_account.changed.include?('transfer_frequency')
        interval_frequency, interval_count, trial_period_days = user_bank_account.transfer_type
        amount_to_cents = (user_bank_account.amount_transfer.to_f * 100).to_i
        plan_name       = "#{self.profile.first_name.titleize} #{user_bank_account.transfer_frequency} Savings Plan"

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
          else
            puts "not delete previous plan"
          end

          stripe_subscription = stripe_customer.subscriptions.create({ plan: stripe_plan.id, metadata: { user_id: self.id } })

          user_subscription.update_attributes({
            plan_id:          stripe_plan.id,
            amount:           stripe_plan.amount,
            interval:         stripe_plan.interval,
            interval_count:   stripe_plan.interval_count,
            subscription_id:  stripe_subscription.id,
            plan_name:        plan_name
          })

          StripeMailer.subscription_updated(self.id).deliver_now
        else
          stripe_subscription = stripe_customer.subscriptions.create({ plan: stripe_plan.id, metadata: { user_id: self.id } })

          Subscription.create(
            plan_id:        stripe_plan.id,
            subscription_id: stripe_subscription.id,
            amount:         stripe_plan.amount,
            currency:       stripe_plan.currency,
            interval:       stripe_plan.interval,
            interval_count: stripe_plan.interval_count,
            plan_name:      stripe_plan.name,
            user_id: id
          )

          StripeMailer.subscription_created(self.id).deliver_now
        end
      end
    end
  end

  def self.get_autocomplete_data(email, current_user)
    self.joins(:profile)
      .joins("FULL OUTER JOIN users_groups ON users_groups.user_id = users.id")
      .joins("FULL OUTER JOIN groups ON groups.user_id = users.id")
      .select("users.id, users.email, profiles.first_name")
      .where("(LOWER(profiles.first_name) LIKE LOWER(:keyword) OR users.email LIKE :keyword)
        AND users.id NOT IN (:ids)", { keyword: "%#{email}%", ids: current_user} )
      .where("users_groups.user_id IS NULL OR users.id IS NULL")
      .where("groups.user_id IS NULL OR users.id IS NULL")
      .map {|u| { id: u.id, name: "#{u.first_name} (#{u.email})" } }
  end
end
