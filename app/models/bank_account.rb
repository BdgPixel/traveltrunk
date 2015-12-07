class BankAccount < ActiveRecord::Base
  belongs_to :user

  attr_accessor :exp_month, :exp_year, :card_number, :stripe_token

  validates :amount_transfer, presence: true
  validates :transfer_frequency, presence: { message: 'please select one' }

  def transfer_type
    case  transfer_frequency
    when "Daily"
      ["day", 1, 1]
    when "Weekly"
      ["week", 1, 7]
    when "Bi Weekly"
      ["week", 2, 14]
    else
      ["month", 1, 31]
    end
  end

end
