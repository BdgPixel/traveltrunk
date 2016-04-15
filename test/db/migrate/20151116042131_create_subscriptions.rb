class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.string :plan_id
      t.string :subscription_id
      t.integer :amount
      t.string :interval
      t.integer :interval_count
      t.string :plan_name
      t.string :currency
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
