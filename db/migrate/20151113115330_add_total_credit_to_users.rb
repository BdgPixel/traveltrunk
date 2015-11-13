class AddTotalCreditToUsers < ActiveRecord::Migration
  def change
    add_column :users, :total_credit, :integer, default: 0
  end
end
