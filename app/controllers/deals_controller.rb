class DealsController < ApplicationController
  require 'htmlentities'

  # before_action :set_search_data, only: [:index, :search]
  before_action :create_destination, only: [:search]
  # before_action :set_search_data, only: [:index, :search]
  # before_action :set_search_data, only: [:search]
  before_action :check_like, only: [:like]
  before_action :authenticate_user!

  def index
    if request.xhr?
      set_search_data
      respond_to :js
    end
  end

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
    destination = current_user.destination
    arrival_date = Date.strptime(destination_params[:arrival_date], '%m/%d/%Y')
    departure_date = Date.strptime(destination_params[:departure_date], '%m/%d/%Y')
    custom_params = destination_params
    custom_params.merge!({ "arrival_date" => arrival_date, "departure_date" => departure_date })

    if destination
      destination.update(custom_params)
    else
      destination = current_user.build_destination(custom_params)
      destination.save
    end
    set_search_data
    # binding.pry
    # destination.user_id = current_user.id
    # destination.destination_string = params["destinationString"]
    # destination.city = params["city"]
    # destination.state_province_code = params["stateProvinceCode"]
    # destination.country_code = params["countryCode"]
    # destination.latitude = params["lat"]
    # destination.longitude = params["lng"]
    # destination.user_id = current_user.id
    # byebug
    # render json: destination
  end

  def set_hotel(params)
    url = "http://api.ean.com/ean-services/rs/hotel/v3/list"
    if params

      params.merge!({
        cid: 55505,
        minorRev: 28,
        apiKey: '5fd6485clmp3oogs8gfb43p2uf',
        locale: 'en_US',
        currencyCode: 'USD'})

      response = HTTParty.get(url + "?" + params.to_query)
      puts response.code
      puts response.message
      # request = Typhoeus::Request.new(url, params: params, headers: { Accept: 'application/json' })

      # request.on_complete do |response|
      #   if response.success?
      #     puts("success")
      #   elsif response.timed_out?
      #     puts("got a time out")
      #   elsif response.code.eql? 0
      #     puts(response.return_message)
      #   else
      #     puts("HTTP request failed: " + response.code.to_s)
      #   end
      # end

      # request.run
      # response = JSON.parse(request.response.body || [])
      # response = request.body
      @hotels_list = response["HotelListResponse"]["HotelList"]["HotelSummary"]

      @hotel_list_cache_key = response["HotelListResponse"]["cacheKey"]
      @hotel_list_cache_location = response["HotelListResponse"]["cacheLocation"]

      @hotel_ids = response["HotelListResponse"]["HotelList"]["HotelSummary"].map { |hotel| hotel["hotelId"] }
      @like_ids = Like.where(hotel_id: @hotel_ids, user_id: current_user.id).pluck(:hotel_id)
      # binding.pry
    else
      @hotels_list = []
    end
  end

  private
    def set_search_data
        # if current_user && current_user.destinations
        #   current_user.destinations.last
        # else
        #   nil
        # end

      if @destination = current_user.destination
        @searchParams = @destination.get_search_params
      end
      # yuhuu
      set_hotel(@searchParams)
    end



    def check_like
      @like = Like.find_by(hotel_id: params[:id], user_id: current_user.id)
    end

    def destination_params
      params.require(:search_deals).permit(:destination_string, :city, :state_province_code, :country_code, :latitude, :longitude, :arrival_date, :departure_date, :postal_code)
      # params.require(:search_deals).permit(:destination_string, :city, :state_province_code, :country_code, :latitude, :longitude, :arrival_date, :departure_date)
    end
end
