class CreatePromoCodes < ActiveRecord::Migration
  def change
    create_table :promo_codes do |t|
      t.string :token
      t.decimal :amount, precision: 8, scale: 2
      t.date :exp_date
      t.string :status, default: 'available'
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
