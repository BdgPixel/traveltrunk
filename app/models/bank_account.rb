class BankAccount < ActiveRecord::Base
  belongs_to :user

  attr_accessor :exp_month, :exp_year, :card_number

  validates :account_number, :amount_transfer, presence: true
  validates :transfer_frequency, presence: { message: 'please select one' }


  def transfer_type
    case  transfer_frequency
    when "Daily"
      ["day", 1]
    when "Weekly"
      ["week", 1]
    when "Bi Weekly"
      ["week", 2]
    else
      ["mont", 1]
    end
  end

end
