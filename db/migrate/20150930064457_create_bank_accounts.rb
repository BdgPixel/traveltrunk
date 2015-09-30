class CreateBankAccounts < ActiveRecord::Migration
  def change
    create_table :bank_accounts do |t|
      t.string :bank_name
      t.string :account_number
      t.string :routing_number
      t.decimal :amount_transfer
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
