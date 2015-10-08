class DealsController < ApplicationController
  before_action :set_search_data, only: [:index, :search]

  def index; end

  def search; end

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
          :propertyCategory => params[:search_deals][:property_category].reject(&:empty?).join(','),
          :roomGroup => {
            :room => {
              :numberOfAdults => params[:search_deals][:guest_list]
            }
          },
          :moreResultsAvailable => true,
          :numberOfResults => 12
        }
      end

      if session[:last_destination_search]
        api = Expedia::Api.new
        response = api.get_list(session[:last_destination_search] )

        response.exception?
        if response.exception?.eql? true
          @error_response = response.presentation_message
          @hotels_list = []
        else
          @hotels_list = response.body["HotelListResponse"]["HotelList"]["HotelSummary"]
        end
      end

    end

end
