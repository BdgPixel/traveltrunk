class FlightsController < ApplicationController
  include ExceptionErrorResponse
	# before_action :set_session_flight

	def index
		@airports = Place.all.pluck(:place_name, :place_id)
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
		params.require(:flights).permit(:origin_place, :destination_place, :outbounddate, :inbounddate, :number_of_adult)
	end

	def set_session_flight
		@flights = Skyscanner::Flights.list_flight("US", "USD", "en-GB", flight_params[:origin_place], flight_params[:destination_place], flight_params[:outbounddate], flight_params[:inbounddate], flight_params[:number_of_adult])
	end
end
