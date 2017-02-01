# == Schema Information
#
# Table name: flights
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Flight < ActiveRecord::Base
  attr_accessor :origin_place, :origin_place_hide, :destination_place, :destination_place_hide, :outbounddate, :inbounddate, :number_of_adult
end
