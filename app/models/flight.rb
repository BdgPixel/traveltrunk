class Flight < ActiveRecord::Base
  attr_accessor :origin_place, :destination_place, :outbounddate, :inbounddate, :number_of_adult
end
