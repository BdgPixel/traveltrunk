class DealsController < ApplicationController
  require 'htmlentities'

  before_action :create_destination, only: [:search]
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

  def next
    if request.xhr?
      set_search_data
      respond_to do |format|
        format.js { render :action => "index" }
      end
    end
  end

  def previous
    if request.xhr?
      set_search_data
      respond_to :js
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
  end

  def set_hotel(params, params_cache = nil)
    url = "http://api.ean.com/ean-services/rs/hotel/v3/list"

    if params
      params_api = {
        cid: 55505,
        minorRev: 28,
        apiKey: '5fd6485clmp3oogs8gfb43p2uf',
        locale: 'en_US',
        currencyCode: 'USD'
      }

      if params_cache
        puts 'cache'
        params_api.merge!(params_cache)
        response = HTTParty.get(url + "?" + params_api.to_query)
        @params_cache = params_cache
      else
        puts 'asdf'
        params.merge!(params_api)
        response = HTTParty.get(url + "?" + params.to_query)
      end
      response.code
      response.message

      @hotels_list = response["HotelListResponse"]["HotelList"]["HotelSummary"]

      @hotel_list_cache_key = response["HotelListResponse"]["cacheKey"]
      @hotel_list_cache_location = response["HotelListResponse"]["cacheLocation"]

      @hotel_ids = response["HotelListResponse"]["HotelList"]["HotelSummary"].map { |hotel| hotel["hotelId"] }
      @like_ids = Like.where(hotel_id: @hotel_ids, user_id: current_user.id).pluck(:hotel_id)
    else
      @hotels_list = []
    end
  end

  private
    def set_search_data
      if @destination = current_user.destination
        @searchParams = @destination.get_search_params
      end
      @page = params[:page].to_i + 1
      params_cache = { cacheKey: params[:cache_key], cacheLocation: params[:cache_location]} if params[:cache_key] && params[:cache_location]
      set_hotel(@searchParams, params_cache)
    end

    def check_like
      @like = Like.find_by(hotel_id: params[:id], user_id: current_user.id)
    end

    def destination_params
      params.require(:search_deals).permit(:destination_string, :city, :state_province_code, :country_code, :latitude, :longitude, :arrival_date, :departure_date, :postal_code)
    end
end
