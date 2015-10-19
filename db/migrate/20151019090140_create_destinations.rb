class CreateDestinations < ActiveRecord::Migration
  def change
    create_table :destinations do |t|
      t.string :destination_string
      t.string :city
      t.string :state_province_code
      t.string :country_code
      t.string :latitude
      t.string :longitude
      t.date :arrival_date
      t.date :departure_date
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
