class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.references :user, index: true, foreign_key: true
      t.string :transaction_type
      t.integer :amount
      t.string :customer_id
      t.string :invoice_id

      t.timestamps null: false
    end
  end
end
