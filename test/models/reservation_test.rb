# == Schema Information
#
# Table name: reservations
#
#  id                  :integer          not null, primary key
#  user_id             :integer
#  itinerary           :string
#  confirmation_number :string
#  arrival_date        :date
#  departure_date      :date
#  hotel_name          :string
#  hotel_address       :text
#  city                :string
#  country_code        :string
#  postal_code         :string
#  number_of_room      :string
#  room_description    :text
#  number_of_adult     :integer
#  total               :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  reservation_type    :string           default("person")
#  status              :string           default("reserved")
#  email               :string
#  status_code         :string
#

require 'test_helper'

class ReservationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
