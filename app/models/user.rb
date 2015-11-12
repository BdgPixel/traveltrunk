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

  accepts_nested_attributes_for :profile
  accepts_nested_attributes_for :bank_account

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

  def set_stripe_customer(api_key, token)
    Stripe.api_key = api_key
    begin
      if self.customer
        customer = Stripe::Customer.retrieve(self.customer.customer_id)
      else
        customer = Stripe::Customer.create(
          email: self.email,
          source: token
        )
        Customer.create(customer_id: customer.id, user_id: id)
      end
    rescue Stripe::CardError => e
      logger.error e.message
    end
  end

  def set_stripe_plan(api_key, transfer_interval)
    Stripe.api_key  = api_key
    amount_to_cents = self.bank_account.amount_transfer.to_f * 100

    begin
      if self.plan
        plan = Stripe::Plan.retrieve(self.plan.plan_id)
      else
        plan = Stripe::Plan.create(
          id:             "gold",
          currency:       "usd",
          name:           "Amazing Gold Plan",
          amount:         amount_to_cents.to_i,
          interval:       transfer_interval[:frequency],
          interval_count: transfer_interval[:recurring_count]
        )
        Plan.create(plan_id: plan.id, user_id: self.id)
      end
    rescue Stripe::CardError => e
      logger.error e.message
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
