class CreateRefunds < ActiveRecord::Migration
  def change
    create_table :refunds do |t|
      t.references :user, index: true, foreign_key: true
      t.string :trans_id
      t.string :confirmed, default: 'pending'
      t.integer :amount

      t.timestamps null: false
    end
  end
end