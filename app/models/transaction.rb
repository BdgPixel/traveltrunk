class Transaction < ActiveRecord::Base
  after_create :update_user_total_credit
  after_create :create_activity

  belongs_to :user

  paginates_per 3

  private
  def update_user_total_credit
    self.user.total_credit += self.amount
    self.user.save
  end

  def create_activity
    activity_key = 
      if ["recurring_billing", "first_recurring_billing"].include? self.transaction_type
        'payment.recurring'
      else
        'payment.manual'
      end

    self.user.create_activity(
      key: activity_key, 
      owner: self.user,
      recipient: self.user, 
      parameters: { 
        amount: self.amount / 100.0, 
        total_credit: self.user.total_credit / 100.0,
        trans_id: self.trans_id,
        is_request_refund: false 
      }
    )
  end
end
