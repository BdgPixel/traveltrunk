module HotelsList
  def api_params_hash(options = nil)
    options     = options || "HOTEL_SUMMARY,ROOM_RATE_DETAILS"
    params_hash = {
      cid:          55505,
      minorRev:     30,
      apiKey:       "5fd6485clmp3oogs8gfb43p2uf",
      locale:       "en_US",
      currencyCode: "USD",
      supplierType: "E",
    }
  end

  def get_room_images(custom_params)
    url                = "http://api.ean.com/ean-services/rs/hotel/v3/roomImages?"
    url_custom_params  = url + custom_params.merge!(api_params_hash).to_query
    response           = HTTParty.get(url_custom_params)
    @room_images       = response["HotelRoomImageResponse"]["RoomImages"]["RoomImage"]
  end

  def get_room_availability(custom_params)
    url                = "http://api.ean.com/ean-services/rs/hotel/v3/avail?"
    url_custom_params  = url + custom_params.merge!(api_params_hash).to_query
    response           = HTTParty.get(url_custom_params)
    @room_availability = response["HotelRoomAvailabilityResponse"]
  end

  def get_hotel_information(custom_params)
    @like              = Like.find_by(hotel_id: custom_params[:hotelId], user_id: current_user)
    @members_liked     = User.joins(:likes, :joined_groups).where("likes.hotel_id = ? AND groups.user_id = ?", custom_params[:hotelId], current_user)

    url                = "http://api.ean.com/ean-services/rs/hotel/v3/info?"
    url_custom_params  = url + custom_params.merge!(api_params_hash(0)).to_query
    response           = HTTParty.get(url_custom_params)
    @hotel_information = response["HotelInformationResponse"]
  end

  def get_hotels_list(custom_params, params_cache = nil)
    url = "http://api.ean.com/ean-services/rs/hotel/v3/list?"

    if custom_params
      url_custom_params = url +
        if params_cache
          api_params_hash.merge!(params_cache).to_query
        else
          custom_params.merge!(api_params_hash("HOTEL_SUMMARY")).to_query
        end

      if params_cache
        response      = HTTParty.get(url_custom_params)
        @params_cache = params_cache
      else
        response      = HTTParty.get(url_custom_params)
      end

      @hotel_ids                 = response["HotelListResponse"]["HotelList"]["HotelSummary"].map { |hotel| hotel["hotelId"] }
      @like_ids                  = Like.where(hotel_id: @hotel_ids, user_id: current_user.id).pluck(:hotel_id)

      @hotels_list               = response["HotelListResponse"]["HotelList"]["HotelSummary"]
      @hotel_list_cache_key      = response["HotelListResponse"]["cacheKey"]
      @hotel_list_cache_location = response["HotelListResponse"]["cacheLocation"]

    end
  end
end
