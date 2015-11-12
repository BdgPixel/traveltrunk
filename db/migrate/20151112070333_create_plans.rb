class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.string :plan_id
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
