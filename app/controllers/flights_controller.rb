class FlightsController < ApplicationController
  include ExceptionErrorResponse

	def index
	end

	def depart_typeahead
		query = params[:query].humanize
		image = ActionController::Base.helpers.asset_path('departures.png')
		places = Place.where("place_name LIKE ? OR place_id LIKE ? OR country_name LIKE ?", "%#{query}%", "%#{query}%", "%#{query}%").map do |pl|
						{ 
							id: pl.place_id,
							name: pl.place_name,
							country: pl.country_name,
							image: image
						}
						end		
		render json: places
	end
	
	def arrival_typeahead
		query = params[:query].humanize
		image = ActionController::Base.helpers.asset_path('arrival.png')
		places = Place.where("place_name LIKE ? OR place_id LIKE ? OR country_name LIKE ?", "%#{query}%", "%#{query}%", "%#{query}%").map do |pl|
						{ 
							id: pl.place_id,
							name: pl.place_name,
							country: pl.country_name,
							image: image
						}
						end		
		render json: places
	end

	def search
		set_session_flight
    respond_to do |format|
      format.html
      format.js
    end
	end

	private
	def flight_params
		params.require(:flights).permit(:origin_place, :destination_place, :origin_place_hide, :destination_place_hide, :outbounddate, :inbounddate, :number_of_adult)
	end

	def set_session_flight
		@flights = Skyscanner::Flights.list_flight("US", "USD", "en-GB", flight_params[:origin_place_hide], flight_params[:destination_place_hide], flight_params[:outbounddate], flight_params[:inbounddate], flight_params[:number_of_adult])
	end
end
