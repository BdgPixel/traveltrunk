class CreateRefunds < ActiveRecord::Migration
  def change
    create_table :refunds do |t|
      t.references :user, index: true, foreign_key: true
      t.string :trans_id
      t.integer :amount
      t.string :confirmed, default: 'pending'

      t.timestamps null: false
    end
  end
end
