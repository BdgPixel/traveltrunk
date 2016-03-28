class User < ActiveRecord::Base
  include PublicActivity::Model

  has_one  :profile, dependent: :destroy
  has_one  :bank_account, dependent: :destroy
  has_one  :group, dependent: :destroy
  has_one  :customer, dependent: :destroy
  has_one  :subscription, dependent: :destroy
  has_one  :destination, dependent: :destroy, as: :destinationable

  has_many :promo_codes, dependent: :destroy
  has_many :likes
  has_many :joined_groups, -> { where("users_groups.accepted_at IS NOT NULL") } , through: :users_groups
  has_many :users_groups, dependent: :destroy
  has_many :transactions, dependent: :destroy
  has_many :reservations, dependent: :destroy
  has_many :refunds, dependent: :destroy

  accepts_nested_attributes_for :profile
  # accepts_nested_attributes_for :bank_account

  # before_save :set_stripe_customer, :set_stripe_subscription

  attr_accessor :stripe_token, :execute_stripe_callbacks, :group_id

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable


  def no_profile?
    self.profile.nil? || self.profile.new_record?
  end

  def full_name
    "#{self.profile.first_name} #{self.profile.last_name}".titleize
  end

  def total_credit_in_usd
    (self.total_credit / 100.0).round
  end

  def total_credit_in_cents(total_credit)
    self.total_credit += total_credit * 100
  end

  def get_notification(is_read = true)
    PublicActivity::Activity.order("created_at desc")
      .where(recipient_id: self.id, recipient_type: "User", is_read: is_read)
  end

  # def get_current_destination()
  #   if destination  = self.destination
  #     search_params = destination.get_search_params
  #   end
  # end

  def expedia_room_params(hotel_id, destination, group, rate_code = nil, room_type_code = nil)
    room_hash = {}

    if destination
      current_search = destination.get_search_params(group)

      room_hash[:hotelId]       = hotel_id.to_s
      room_hash[:arrivalDate]   = current_search[:arrivalDate]
      room_hash[:departureDate] = current_search[:departureDate]


      if rate_code && room_type_code
        room_hash[:rateCode]     = rate_code
        room_hash[:roomTypeCode] = room_type_code
      end

      room_hash[:includeRoomImages] = 'true'
      room_hash[:options]           = "ROOM_TYPES"
      room_hash[:includeDetails]    = 'true'

      room_hash[:RoomGroup] = {
        'Room' => {
          'numberOfAdults' => group ? group.members.size.next.to_s : '1'
        }
      }
    end

    room_hash
  end

  # commented but will be used later
  #
  # def current_group
  #   self.group || self.joined_groups.first
  # end

  # def members_liked(hotel_id)
  #   group = self.group || self.joined_groups.first

  #   User.joins(:likes).joins("LEFT JOIN users_groups ON users_groups.user_id = users.id")
  #     .where("hotel_id = ? AND (users_groups.group_id = ? OR users.id IN (?))", hotel_id, group.id, [self.id, group.user_id])
  # end

=begin
  def set_stripe_customer
    if self.execute_stripe_callbacks
      begin
        if self.customer
          stripe_customer = Stripe::Customer.retrieve(self.customer.customer_id)
          stripe_customer.source = self.stripe_token
          stripe_customer.save
        else
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
=end

  def self.get_autocomplete_data(email, current_user)
    User.joins("FULL OUTER JOIN profiles ON profiles.user_id = users.id")
      .joins("FULL OUTER JOIN users_groups ON users_groups.user_id = users.id")
      .joins("FULL OUTER JOIN groups ON groups.user_id = users.id")
      .select("users.id, users.email, users.admin, profiles.first_name, profiles.image")
      .where("(LOWER(profiles.first_name) LIKE LOWER(:keyword) OR users.email LIKE :keyword)
        AND users.id NOT IN (:ids)", { keyword: "%#{email}%", ids: [current_user]} )
      .where("users.admin = ?", false)
      .where("users_groups.user_id IS NULL OR users.id IS NULL")
      .where("groups.user_id IS NULL OR users.id IS NULL")
      .map {|u| { id: u.id, name: "#{u.profile.try(:first_name) || 'No Name'}", email: u.email, image_url: u.profile.try(:image_url) || '/assets/default_user.png' } }
  end

  def self.list_of_user_collections
    user_collections = []
    self.includes(:profile).select(:id).where(admin: false).map do |user|
      user_collections << ["#{user.profile.first_name} #{user.profile.last_name}", user.id].to_a if user.profile
    end
    user_collections
  end
end
