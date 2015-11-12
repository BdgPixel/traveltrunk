class BankAccount < ActiveRecord::Base
  belongs_to :user

  validates :bank_name, :account_number, :routing_number, :amount_transfer, presence: true
  validates :transfer_frequency, presence: { message: 'please select one' }

  def transfer_type
    if transfer_frequency.eql? "Weekly"
      transfer_frequency       = "week"
      interval_recurring_count = 1
    elsif transfer_frequency.eql? "Bi Weekly"
      transfer_frequency       = "week"
      interval_recurring_count = 2
    else
      transfer_frequency       = "month"
      interval_recurring_count = 1
    end
    transfer_interval = {
      frequency: transfer_frequency,
      recurring_count: interval_recurring_count
    }
  end

end
