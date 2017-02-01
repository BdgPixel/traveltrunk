# == Schema Information
#
# Table name: promo_codes
#
#  id         :integer          not null, primary key
#  token      :string
#  amount     :decimal(8, 2)
#  exp_date   :date
#  status     :string           default("available")
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

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
      "Expired"
    end
  end

  def is_expired?
    Date.today > self.exp_date
  end
end
