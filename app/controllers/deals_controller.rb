class DealsController < ApplicationController
  def index
    if session[:last_destination_search]
      api = Expedia::Api.new
      response = api.get_list({
        :destinationString => session[:last_destination_search]["city"],
        :arrivalDate => session[:last_destination_search]["arrivalDate"],
        :departureDate => session[:last_destination_search]["departureDate"],
        :moreResultsAvailable => true,
        :numberOfResults => 12})

      response.exception?
      if response.exception?.eql? true
        @error_response = response.presentation_message
        @hotels_list = []
      else
        @hotels_list = response.body["HotelListResponse"]["HotelList"]["HotelSummary"]
      end

    end
  end

  def search
    hotels_list(params["deals"])

    # render 'index'
  end

  def hotels_list(params)
    api = Expedia::Api.new
    response = api.get_list({
      :destinationString => params["destination"],
      :arrivalDate => params["arrival_date"],
      :departureDate => params["departure_date"],
      :propertyCategory => params["propertyCategory"],
      :moreResultsAvailable => true,
      :numberOfResults => 12})

    response.exception?
    if response.exception?.eql? true
      @error_response = response.presentation_message
      @hotels_list = []
    else
      @hotels_list = response.body["HotelListResponse"]["HotelList"]["HotelSummary"]
    end

    session[:last_destination_search] = {
      :city => params["destination"],
      :stateProvinceCode => params["administrative_area_level_1"],
      :countryCode => params["country"],
      :arrivalDate => params["arrival_date"] ,
      :departureDate => params["departure_date"],
    }

  end
end
