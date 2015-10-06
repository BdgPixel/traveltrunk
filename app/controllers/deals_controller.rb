class DealsController < ApplicationController
  def index
    api = Expedia::Api.new
    today = Date.today
    response = api.get_list({
      :destinationString => 'HONOLULU, HI, UNITED STATES',
      :arrivalDate => today.to_date.strftime('%m/%d/%Y') ,
      :departureDate => (today + 4.days).strftime('%m/%d/%Y'),
      :numberOfResults => 12})

    response.exception?
    session[:last_destination] = nil
    @hotels_list = response.body["HotelListResponse"]["HotelList"]["HotelSummary"]
  end

  def search
    hotels_list(params["deals"])

    session[:last_destination] = params["deals"]["destination"]
    render 'index'
  end

  def hotels_list(params)
    api = Expedia::Api.new
    response = api.get_list({
      :city => params["destination"],
      :stateProvinceCode => params["administrative_area_level_1"],
      :countryCode => params["country"],
      :arrivalDate => params["arrival_date"] ,
      :departureDate => params["departure_date"],
      :numberOfResults => 12})

    response.exception?
    @hotels_list = response.body["HotelListResponse"]["HotelList"]["HotelSummary"]
  end
end
