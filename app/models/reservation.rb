class Reservation < ActiveRecord::Base
  belongs_to :user

  # validates :itinerary, :confirmation_number, :hotel_name, :hotel_address, :city, :country_code, :postal_code, :number_of_room, :room_description, :number_of_adult, :total, presence: true
end
