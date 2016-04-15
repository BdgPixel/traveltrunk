class PromoCode < ActiveRecord::Base
  belongs_to :user

  paginates_per 10

  validates :token, :amount, :exp_date, :user_id, presence: true

  attr_accessor :exp_month, :exp_year, :card_number, :stripe_token, :cvc

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
