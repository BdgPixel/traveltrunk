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

  attr_accessor :stripe_token

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
    begin
      if self.customer
        puts "update customer"
        stripe_customer = Stripe::Customer.retrieve(self.customer.customer_id)
        stripe_customer.source = self.stripe_token
        stripe_customer.save
        # stripe_customer.sources.create({ source: self.stripe_token, default_for_currency: true })
        # Stripe::Customer.retrieve(self.customer.customer_id)
        # self.customer.update({ customer_id: stripe_customer.id })
      else
        puts "create new customer"
        stripe_customer = Stripe::Customer.create(
          email: self.email,
          source: self.stripe_token
        )

        Customer.create(customer_id: stripe_customer.id, user_id: id)
        # stripe_customer
      end
    rescue Stripe::CardError => e
      logger.error e.message
      puts e.message
    end
  end

  def set_stripe_subscription
    customer = Customer.where(user_id: self.id).first
    user_bank_account = self.bank_account
    user_subscription = self.subscription

    if user_subscription.nil? || user_bank_account.changed.include?('amount_transfer') || user_bank_account.changed.include?('transfer_frequency')
      interval_frequency, interval_count = user_bank_account.transfer_type
      amount_to_cents = (user_bank_account.amount_transfer.to_f * 100).to_i

      stripe_plan = Stripe::Plan.create(
        id:             SecureRandom.hex,
        currency:       'usd',
        name:           "#{self.profile.first_name.titleize} #{user_bank_account.transfer_frequency} Savings Plan",
        amount:         amount_to_cents,
        interval:       interval_frequency,
        interval_count: interval_count
      )

      stripe_customer = Stripe::Customer.retrieve(customer.customer_id)

      if user_subscription
        puts "update subscription"
        stripe_subscription = stripe_customer.subscriptions.retrieve(user_subscription.subscription_id)
        stripe_subscription.plan = stripe_plan.id
        stripe_subscription.save

        previous_plan = Stripe::Plan.retrieve(user_subscription.plan_id)

        user_subscription.update_attributes({
          plan_id:        stripe_plan.id,
          amount:         stripe_plan.amount,
          interval:       stripe_plan.interval,
          interval_count: stripe_plan.interval_count
        })

        previous_plan.delete
      else
        puts "create subscription"
        stripe_subscription = stripe_customer.subscriptions.create({ plan: stripe_plan.id })

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
      end
    end

    # begin
    #   if self.subscription
    #     # plan = Stripe::Plan.retrieve(self.plan.plan_id)
    #     # user_plan = Plan.find_by(plan_id: plan.id)
    #     # user_plan.destroy
    #     # plan.delete
    #   else
    #   end

    #   plan = Stripe::Plan.create(
    #     # id:             "plan_user_#{id}",
    #     id:             "plan_user_#{SecureRandom.hex}",
    #     currency:       "usd",
    #     name:           "#{self.profile.first_name} savings plan",
    #     amount:         amount_to_cents.to_i,
    #     interval:       interval_frequency,
    #     interval_count: interval_count
    #   )
    #   # Plan.create(plan_id: plan.id, user_id: id)
    #   Subscription.create(plan_id: plan.id, )
    #   plan
    #   # binding.pry
    # rescue Stripe::CardError => e
    #   logger.error e.message
    # end
  end

  def subscribe_to_plan
    stripe_customer = Stripe::Customer.retrieve(self.customer.id)
    stripe_subscription = stripe_customer.subscriptions.create(plan: self.subscription.plan_id)
    self.subscription.update(subscription_id: stripe_subscription.id)
  end

  def cancel_subscriptions
    customer = Stripe::Customer.retrieve(self.customer.customer_id)
    customer.subscriptions.retrieve(self.subscriptions)
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
