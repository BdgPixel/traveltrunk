# == Schema Information
#
# Table name: destinations
#
#  id                   :integer          not null, primary key
#  destination_string   :string
#  city                 :string
#  state_province_code  :string
#  country_code         :string
#  latitude             :string
#  longitude            :string
#  arrival_date         :date
#  departure_date       :date
#  user_id              :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  destinationable_id   :integer
#  destinationable_type :string
#  number_of_adult      :integer
#

require 'test_helper'

class DestinationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
