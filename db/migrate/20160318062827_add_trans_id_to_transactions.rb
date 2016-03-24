class AddTransIdToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :ref_id, :string
    add_column :transactions, :trans_id, :string
  end
end
