class DealsController < ApplicationController
  require 'htmlentities'

  before_action :set_search_data, only: [:index, :search]
  before_action :check_like, only: [:like]
  before_action :authenticate_user!

  def index; end

  def search; end

  def show
    expedia_params_hash = { hotelId: params[:id] }
    set_hotel("get_information", expedia_params_hash)

  end

  def like
    @hotel_id = params[:id]
    if @like.present?
      @like.destroy
    else
      like = Like.new(hotel_id: @hotel_id, user_id: current_user.id)
      like.save
    end
  end

  def create_destination
    destination = Destination.new()
    destination.destination_string = params["destinationString"]
    destination.city = params["city"]
    destination.state_province_code = params["stateProvinceCode"]
    destination.country_code = params["countryCode"]
    destination.latitude = params["lat"]
    destination.longitude = params["lng"]
    destination.arrival_date = params["arrivalDate"]
    destination.departure_date = params["departureDate"]
    destination.user_id = current_user.id
    destination.save
    render json: destination
  end

  private
    def set_search_data
      @destination =
        if current_user && current_user.destination
          current_user.destination.last
        else
          nil
        end
      # current_user ? current_user.destination.last : nil
      # if params[:search_deals]
      if @destination
        session[:last_destination_search] = {
            :latitude => @destination.latitude,
            :longitude => @destination.longitude,
            :searchRadius => 80,
            :destinationString => @destination.destination_string.upcase,
            :city => @destination.city,
            :stateProvinceCode => @destinationstate_province_code,
            :countryCode => @destination.country_code,
            :arrivalDate => @destination.arrival_date.strftime('%m/%d/%Y'),
            :departureDate => @destination.departure_date.strftime('%m/%d/%Y'),
            :options => 'HOTEL_SUMMARY,ROOM_RATE_DETAILS',
            :moreResultsAvailable => true,
            :numberOfResults => 15
          }
        # session[:last_destination_search] = {
        #   :latitude => params[:search_deals][:lat],
        #   :longitude => params[:search_deals][:lng],
        #   :searchRadius => 80,
        #   :destinationString => params[:search_deals][:destination].upcase,
        #   :city => params[:search_deals][:locality],
        #   :stateProvinceCode => params[:search_deals][:administrative_area_level_1],
        #   :countryCode => params[:search_deals][:country],
        #   :arrivalDate => params[:search_deals][:arrival_date] ,
        #   :departureDate => params[:search_deals][:departure_date],
        #   :options => 'HOTEL_SUMMARY,ROOM_RATE_DETAILS',
        #   :moreResultsAvailable => true,
        #   :numberOfResults => 21
        # }
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
            # api.get_information({hotelId: 356564, options: "HOTEL_SUMMARY,HOTEL_DETAILS,HOTEL_IMAGES"})
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
          # yuhuu

          if event.eql? "get_list"
            @hotel_ids = @hotels_list.map { |hotel| hotel["hotelId"] }
            @like_ids = Like.where(hotel_id: @hotel_ids, user_id: current_user.id).pluck(:hotel_id)

            @hotel_list_cache_key = response.body["HotelListResponse"]["cacheKey"]
            @hotel_list_cache_location = response.body["HotelListResponse"]["cacheLocation"]
          end

        end
      end
    end

    def check_like
      @like = Like.find_by(hotel_id: params[:id], user_id: current_user.id)
    end

    # def destination_params
    #   params.require(:destination).permit(:destination_string, :city, :state_province_code, :country_code, :latitude, :longitude, :arrival_date, :departure_date)
    # end

end
