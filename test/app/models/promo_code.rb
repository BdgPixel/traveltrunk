class PromoCode < ActiveRecord::Base
  belongs_to :user

  validates :token, :amount, :exp_date, :user_id, presence: true

  def displayed_status
    today = Date.today

    if today <= self.exp_date
      self.status
    else
      "Expired date"
    end
  end

  def is_expired?
    Date.today > self.exp_date
  end
end
