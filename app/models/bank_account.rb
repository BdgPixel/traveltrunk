class BankAccount < ActiveRecord::Base
  belongs_to :user

  validates :bank_name, :account_number, :routing_number, :amount_transfer, presence: true
  validates :transfer_frequency, presence: { message: 'please select one' }
end
