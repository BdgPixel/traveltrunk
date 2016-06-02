class Destination < ActiveRecord::Base
  belongs_to :destinationable, polymorphic: true

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
