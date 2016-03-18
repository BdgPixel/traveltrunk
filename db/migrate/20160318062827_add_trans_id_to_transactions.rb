class AddTransIdToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :trans_id, :string
  end
end
