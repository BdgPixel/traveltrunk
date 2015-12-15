class Destination < ActiveRecord::Base
  belongs_to :destinationable, polymorphic: true

  def get_search_params
    today = Date.today
    if arrival_date < today
      new_arrival_date = today
      new_departure_date = new_arrival_date + (departure_date - arrival_date).to_i
    else
      new_arrival_date = arrival_date
      new_departure_date = departure_date
    end

    {
      latitude: latitude,
      longitude: longitude,
      searchRadius: 80,
      destinationString: destination_string.upcase,
      city: city,
      stateProvinceCode: state_province_code,
      countryCode: country_code,
      arrivalDate: new_arrival_date.strftime('%m/%d/%Y'),
      departureDate: new_departure_date.strftime('%m/%d/%Y'),
      options: 'HOTEL_SUMMARY,ROOM_RATE_DETAILS',
      moreResultsAvailable: true,
      numberOfResults: 15
    }
  end

  def title_destination
    destination_string.split(", ").first
  end
end
