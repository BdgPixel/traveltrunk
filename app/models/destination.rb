class Destination < ActiveRecord::Base
  belongs_to :destinationable, polymorphic: true

  attr_accessor :number_of_adult

  def get_search_params(group)
    today_utc = Time.now.utc.to_date

    if self.arrival_date < today_utc
      self.departure_date = today_utc + (self.departure_date - self.arrival_date).to_i
      self.arrival_date = today_utc
    end

    {
      latitude: latitude,
      longitude: longitude,
      searchRadius: '10',
      destinationString: destination_string.upcase,
      city: city,
      stateProvinceCode: state_province_code,
      countryCode: country_code,
      arrivalDate: self.arrival_date.strftime('%m/%d/%Y'),
      departureDate: self.departure_date.strftime('%m/%d/%Y'),
      options: 'HOTEL_SUMMARY,ROOM_RATE_DETAILS',
      moreResultsAvailable: 'true',
      'RoomGroup' => {
        'Room' => {
          'numberOfAdults' => group ? group.members.size.next.to_s : '1'
        }
      },
      numberOfResults: '200',
      includeSurrounding: 'yes'
    }
  end

  def self.get_session_search_hashes(destination, group)
    today_utc = Date.today
    arrival_date = 
      if destination['arrival_date'].is_a?(Date)
        destination['arrival_date']
      else
        Date.parse destination['arrival_date']
      end

    departure_date = 
      if destination['departure_date'].is_a?(Date)
        destination['departure_date']
      else
        Date.parse destination['departure_date']
      end

    if arrival_date < today_utc
      destination['departure_date'] = today_utc + (departure_date - arrival_date).to_i
      destination['arrival_date'] = today_utc
    end

    {
      latitude: destination['latitude'],
      longitude: destination['longitude'],
      searchRadius: '10',
      destinationString: destination['destination_string'].upcase,
      city: destination['city'],
      stateProvinceCode: destination['state_province_code'],
      countryCode: destination['country_code'],
      arrivalDate: arrival_date.strftime('%m/%d/%Y'),
      departureDate: departure_date.strftime('%m/%d/%Y'),
      options: 'HOTEL_SUMMARY,ROOM_RATE_DETAILS',
      moreResultsAvailable: 'true',
      'RoomGroup' => {
        'Room' => {
          'numberOfAdults' => group ? group.members.size.next.to_s : destination['number_of_adult']
        }
      },
      numberOfResults: '100',
      includeSurrounding: 'yes'
    }
  end

  def title_destination
    destination_string.split(", ").first
  end

  def update_arrival_and_departure_date
    new_arrival_date = Time.zone.now.to_date

    if self.arrival_date < new_arrival_date
      self.departure_date = new_arrival_date + (self.departure_date - self.arrival_date).to_i
      self.arrival_date = new_arrival_date
      self.save
    end
  end
end
