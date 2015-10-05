class DealsController < ApplicationController
  def index
    api = Expedia::Api.new
    today = Date.today
    response = api.get_list({
      :destinationId => '76AC2A5C-6AB7-4B6C-B618-387169A79F5E',
      :arrivalDate => today.to_date.strftime('%m/%d/%Y') ,
      :departureDate => (today + 4.days).strftime('%m/%d/%Y'),
      :numberOfResults => 12})

    response.exception?
    @hotels_list = response.body["HotelListResponse"]["HotelList"]["HotelSummary"]
  end

  def search
    api = Expedia::Api.new
    today = Date.today
    response = api.get_list({
      :destinationId => params["deals"]["destination"],
      :arrivalDate => params["deals"]["arrival_date"] ,
      :departureDate => params["deals"]["depature_date"],
      :numberOfResults => 12})

    response.exception?
    @hotels_list = response.body["HotelListResponse"]["HotelList"]["HotelSummary"]
    render 'index'
  end
end
