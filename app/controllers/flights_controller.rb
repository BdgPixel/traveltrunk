class FlightsController < ApplicationController
  include ExceptionErrorResponse

	def index
	end

	def depart_typeahead
		query = params[:query].downcase
		image = ActionController::Base.helpers.asset_path('departures.png')
		places = Place.where("lower(place_name) LIKE ? OR lower(place_id) LIKE ? OR lower(country_name) LIKE ?", "#{query}%", "#{query}%", "#{query}%").map do |pl|
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
		query = params[:query].downcase
		image = ActionController::Base.helpers.asset_path('arrival.png')
		places = Place.where("lower(place_name) LIKE ? OR lower(place_id) LIKE ? OR lower(country_name) LIKE ?", "#{query}%", "#{query}%", "#{query}%").map do |pl|
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
		@title 			= flight_params[:origin_place] + " to "+ flight_params[:destination_place]
		session[:title] = flight_params[:origin_place] + " to "+ flight_params[:destination_place]
    respond_to do |format|
      format.html
      format.js
    end
	end

	private
	def flight_params
		params.require(:flights).permit(:origin_place, :destination_place, :origin_place_hide, :destination_place_hide, :outbounddate, :inbounddate, :number_of_adult, :origin_place_hide_2, :destination_place_hide_2)
	end

	def set_session_flight
		if flight_params[:destination_place_hide_2].present? && flight_params[:origin_place_hide_2].present? 
			params[:flights][:destination_place_hide] = flight_params[:destination_place_hide_2]
			params[:flights][:origin_place_hide] = flight_params[:origin_place_hide_2]
		end
		@flights = Skyscanner::Flight.list_flight("US", "USD", "en-GB", flight_params[:origin_place_hide], flight_params[:destination_place_hide], flight_params[:outbounddate], flight_params[:inbounddate], flight_params[:number_of_adult])
		session[:destination_flight] = { 
			destination_string: flight_params[:destination_place]
		}
	end
end
