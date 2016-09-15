class AddDateToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :transaction_date, :datetime, default: Time.now
  end
end
