class FlightDestination < ActiveRecord::Base
  belongs_to :flightable, polymorphic: true

  def destination_name
    "#{self.origin_place} to #{self.destination_place}"  
  end
end
