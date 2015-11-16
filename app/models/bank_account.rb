class BankAccount < ActiveRecord::Base
  belongs_to :user

  # after_save :bank_account

  attr_accessor :exp_month, :exp_year, :card_number, :stripe_token

  validates :account_number, :amount_transfer, presence: true
  validates :transfer_frequency, presence: { message: 'please select one' }

  # def bank_account
  #   customer = Stripe::Customer.retrieve(user.customer.customer_id)

  #   if self.changed
  #     # subscription = customer.subscriptions.retrieve(user.subscription.subscription_id).delete
  #     # user.subscription.destroy
  #     interval_frequency, interval_count = self.transfer_type
  #     plan = user.set_stripe_plan('sk_test_ZqnJoRfoLZjcJQzgBjmqpJGy', interval_frequency, interval_count)
  #   # else
  #   #   subscription = customer.subscriptions.create(plan: plan.id, metadata: { user_id: current_user.id })
  #   end
  # end

  def transfer_type
    case  transfer_frequency
    when "Daily"
      ["day", 1]
    when "Weekly"
      ["week", 1]
    when "Bi Weekly"
      ["week", 2]
    else
      ["month", 1]
    end
  end

end
