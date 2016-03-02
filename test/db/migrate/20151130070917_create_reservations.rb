class CreateReservations < ActiveRecord::Migration
  def change
    create_table :reservations do |t|
      t.references :user, index: true, foreign_key: true
      t.string :itinerary
      t.string :confirmation_number
      t.date :arrival_date
      t.date :departure_date
      t.string :hotel_name
      t.text :hotel_address
      t.string :city
      t.string :country_code
      t.string :postal_code
      t.string :number_of_room
      t.text :room_description
      t.integer :number_of_adult
      t.integer :total

      t.timestamps null: false
    end
  end
end
