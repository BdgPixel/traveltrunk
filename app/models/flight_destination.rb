# == Schema Information
#
# Table name: flight_destinations
#
#  id                     :integer          not null, primary key
#  currency               :string           default("USD")
#  locale                 :string           default("en-GB")
#  origin_place           :string
#  origin_place_hide      :string
#  destination_place      :string
#  destination_place_hide :string
#  outbounddate           :date
#  inbounddate            :date
#  cabin_class            :string
#  number_of_adult        :string
#  number_of_children     :string
#  number_of_infants      :string
#  flightable_id          :integer
#  flightable_type        :string
#  user_id                :integer
#  section_type           :string           default("RoundTrip")
#

class FlightDestination < ActiveRecord::Base
  belongs_to :flightable, polymorphic: true

  def destination_name
    "#{self.origin_place} to #{self.destination_place}"  
  end
end
