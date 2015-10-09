class DealsController < ApplicationController
  require 'htmlentities'
  before_action :set_search_data, only: [:index, :search]

  def index; end

  def search; end

  def show
    expedia_params_hash = { hotelId: params[:id] }
    set_hotel("get_information", expedia_params_hash)
  end

  private
    def set_search_data
      if params[:search_deals]
        session[:last_destination_search] = {
          :destinationString => params[:search_deals][:destination].upcase,
          :city => params[:search_deals][:locality],
          :stateProvinceCode => params[:search_deals][:administrative_area_level_1],
          :countryCode => params[:search_deals][:country],
          :arrivalDate => params[:search_deals][:arrival_date] ,
          :departureDate => params[:search_deals][:departure_date],
          :moreResultsAvailable => true,
          :numberOfResults => 12
        }
      end
      set_hotel("get_list", session[:last_destination_search])

    end

    def set_hotel(event, params)
      if params
        api = Expedia::Api.new
        response =
          if event.eql? "get_list"
            api.get_list(params)
          elsif event.eql? "get_information"
            api.get_information(params)
          end

        response.exception?
        if response.exception?.eql? true
          @error_response = response.presentation_message
          @hotels_list = []
        else
          @hotels_list =
            if event.eql? "get_list"
              response.body["HotelListResponse"]["HotelList"]["HotelSummary"]
            elsif event.eql? "get_information"
              response.body["HotelInformationResponse"]
            end
        end

      end

  end

end
