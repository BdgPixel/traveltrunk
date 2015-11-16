class User < ActiveRecord::Base
  has_one  :profile
  has_one  :bank_account
  has_many :likes
  # has_many :destinations
  has_one  :destination
  has_many :joined_groups, -> { where("users_groups.accepted_at IS NOT NULL") } , through: :users_groups
  has_many :users_groups
  has_one  :group
  has_one  :customer
  has_one  :plan
  has_many :transactions
  has_one :subscription

  accepts_nested_attributes_for :profile
  accepts_nested_attributes_for :bank_account

  before_save :set_stripe_customer, :set_stripe_subscription

  attr_accessor :stripe_token, :skip_callbacks

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable


  def no_profile?
    self.profile.nil? || self.profile.new_record?
  end

  def full_name
    full_name = "#{self.profile.first_name} #{self.profile.last_name}".titleize
  end

  def get_notification(is_read = true)
    PublicActivity::Activity.order("created_at desc")
      .where(recipient_id: self.id, recipient_type: "User", is_read: is_read)
  end

  def get_current_destination
    if destination  = self.destination
      searchParams = destination.get_search_params
    end
  end

  def set_stripe_customer
    unless self.skip_callbacks
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
        puts e.message
      end
    end
  end

  def set_stripe_subscription
    unless self.skip_callbacks
      customer = Customer.where(user_id: self.id).first
      user_bank_account = self.bank_account
      user_subscription = self.subscription

      if user_subscription.nil? || user_bank_account.changed.include?('amount_transfer') || user_bank_account.changed.include?('transfer_frequency')
        interval_frequency, interval_count = user_bank_account.transfer_type
        amount_to_cents = (user_bank_account.amount_transfer.to_f * 100).to_i
        plan_name = "#{self.profile.first_name.titleize} #{user_bank_account.transfer_frequency} Savings Plan"

        stripe_plan = Stripe::Plan.create(
          id:             SecureRandom.hex,
          currency:       'usd',
          name:           plan_name,
          amount:         amount_to_cents,
          interval:       interval_frequency,
          interval_count: interval_count
        )

        stripe_customer = Stripe::Customer.retrieve(customer.customer_id)

        if user_subscription
          stripe_subscription = stripe_customer.subscriptions.retrieve(user_subscription.subscription_id)
          stripe_subscription.plan = stripe_plan.id
          stripe_subscription.metadata = { user_id: self.id }
          stripe_subscription.save

          previous_plan = Stripe::Plan.retrieve(user_subscription.plan_id)

          user_subscription.update_attributes({
            plan_id:        stripe_plan.id,
            amount:         stripe_plan.amount,
            interval:       stripe_plan.interval,
            interval_count: stripe_plan.interval_count,
            plan_name:      plan_name
          })

          StripeMailer.subscription_updated(self.id).deliver_now
          previous_plan.delete
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
