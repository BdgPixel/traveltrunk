module HotelsList
  def api_params_hash(options = nil)
    # options     = options || "HOTEL_SUMMARY,ROOM_RATE_DETAILS"
    params_hash = {
      apiExperience: "PARTNER_WEBSITE",
      cid:          55505,
      minorRev:     30,
      apiKey:       "5fd6485clmp3oogs8gfb43p2uf",
      locale:       "en_US",
      currencyCode: "USD",
      supplierType: "E",
      numberOfResults: 200
    }
  end

  def book_reservation(custom_params)
    url = "https://book.api.ean.com/ean-services/rs/hotel/v3/res?"
    expedia_api = api_params_hash
    expedia_api.delete(:numberOfResults)

    url_custom_params = url + custom_params.merge(expedia_api).to_query

    begin
      response = HTTParty.post(url_custom_params)
      if response["HotelRoomReservationResponse"]["EanWsError"]
        redirect_to deals_book_path(id: params[:confirmation_book][:hotel_id], rate_code: params[:confirmation_book][:rate_code], room_type_code: params[:room_type_code])
      else
        @reservation = response["HotelRoomReservationResponse"]

        ReservationMailer.reservation_created(@reservation).deliver_now
        redirect_to deals_path
      end
    rescue Exception => e
      @error_response = e.message
    end
  end

  def get_room_images(custom_params)
    url         = "http://api.ean.com/ean-services/rs/hotel/v3/roomImages?"
    expedia_api = api_params_hash

    expedia_api.delete(:numberOfResults)

    url_room_images  = url + custom_params.merge!(expedia_api).to_query

    begin
      response           = HTTParty.get(url_room_images)
      @room_images       = response["HotelRoomImageResponse"]["RoomImages"]["RoomImage"]
    rescue Exception => e
      @error_response = e.message
    end
  end

  def get_room_availability(room_params)
    # binding.pry
    url                 = "http://api.ean.com/ean-services/rs/hotel/v3/avail?"
    complete_params     = room_params.merge!(api_params_hash)
    url_room_params     = url + complete_params.to_query
    begin
      response = HTTParty.get(url_room_params)

      if response["HotelRoomAvailabilityResponse"]["EanWsError"]
        @room_availability = []
        @error_response    = response["HotelRoomAvailabilityResponse"]["EanWsError"]["presentationMessage"]
        @category_room_message = response["HotelRoomAvailabilityResponse"]["EanWsError"]["category"]
        # binding.pry
      else
        @room_availability = response["HotelRoomAvailabilityResponse"]
      end
    rescue Exception => e
       @error_response = e.message
    end
  end

  def get_hotel_information(custom_params)
    @like              = Like.find_by(hotel_id: custom_params[:hotelId], user_id: current_user)
    @members_liked     = User.joins(:likes, :joined_groups).where("likes.hotel_id = ? AND groups.user_id = ?", custom_params[:hotelId], current_user)

    url                = "http://api.ean.com/ean-services/rs/hotel/v3/info?"
    url_custom_params  = url + custom_params.merge!(api_params_hash(0)).to_query

    begin
      response = HTTParty.get(url_custom_params)

      if response["HotelInformationResponse"]["EanWsError"]
        @hotel_information = []
        @error_response    = response["HotelInformationResponse"]["EanWsError"]["presentationMessage"]
      else
        @hotel_information = response["HotelInformationResponse"]
      end

    rescue Exception  => e
      @error_response = e.message
    end
  end

  def get_hotels_list(custom_params, params_cache = nil)
    if current_user.total_credit_in_usd > 0
      url            = "http://api.ean.com/ean-services/rs/hotel/v3/list?"
      @is_first_page = params_cache.nil?

      if custom_params
        custom_params.merge!({ maxRate: current_user.total_credit_in_usd })

        url_custom_params = url +
          if params_cache
            api_params_hash.merge!(params_cache).to_query
          else
            custom_params.merge!(api_params_hash).to_query
          end
        # binding.pry
        begin
          response = HTTParty.get(url_custom_params)

          if response["HotelListResponse"]["EanWsError"]
            @hotels_list    = []
            @error_response = response["HotelListResponse"]["EanWsError"]["presentationMessage"]
          else
            # @hotel_ids = response["HotelListResponse"]["HotelList"]["HotelSummary"].map { |hotel| hotel["hotelId"] }
            # @like_ids = Like.where(hotel_id: @hotel_ids, user_id: current_user.id).pluck(:hotel_id)

            hotels_list = response["HotelListResponse"]["HotelList"]["HotelSummary"].select do |hotel|
              hotel["RoomRateDetailsList"]["RoomRateDetails"]["RateInfos"]["RateInfo"]["ChargeableRateInfo"]["@total"].to_f <= (current_user.total_credit / 100.0)
            end



            if hotels_list.empty?
              @error_response = "There is no hotels that match your criteria and saving credits"
            else
              @hotels_list =
                hotels_list.sort do |hotel_x, hotel_y|
                  hotel_y["RoomRateDetailsList"]["RoomRateDetails"]["RateInfos"]["RateInfo"]["ChargeableRateInfo"]["@total"].to_f <=> hotel_x["RoomRateDetailsList"]["RoomRateDetails"]["RateInfos"]["RateInfo"]["ChargeableRateInfo"]["@total"].to_f
                end

            end

            # @hotel_list_cache_key      = response["HotelListResponse"]["cacheKey"]
            # @hotel_list_cache_location = response["HotelListResponse"]["cacheLocation"]
          end
        rescue Exception => e
          @error_response = e.message
        end
      else
        @hotels_list    = []
        @error_response = "You haven't selected any destinations"
      end
    else
      @hotels_list    = []
      @error_response = "You don't have any credits"
    end
  end



  # def get_hotels_list(custom_params, params_cache = nil)
  #   if current_user.total_credit_in_usd > 0
  #     url            = "http://api.ean.com/ean-services/rs/hotel/v3/list?"
  #     @is_first_page = params_cache.nil?

  #     if custom_params
  #       custom_params.merge!({ maxRate: current_user.total_credit_in_usd })

  #       url_custom_params = url +
  #         if params_cache
  #           api_params_hash.merge!(params_cache).to_query
  #         else
  #           custom_params.merge!(api_params_hash).to_query
  #         end
  #       # binding.pry
  #       begin
  #         response = HTTParty.get(url_custom_params)

  #         if response["HotelListResponse"]["EanWsError"]
  #           @hotels_list    = []
  #           @error_response = response["HotelListResponse"]["EanWsError"]["presentationMessage"]
  #         else
  #           @hotel_ids                 = response["HotelListResponse"]["HotelList"]["HotelSummary"].map { |hotel| hotel["hotelId"] }
  #           @like_ids                  = Like.where(hotel_id: @hotel_ids, user_id: current_user.id).pluck(:hotel_id)

  #           @hotels_list               = response["HotelListResponse"]["HotelList"]["HotelSummary"]
  #           @hotel_list_cache_key      = response["HotelListResponse"]["cacheKey"]
  #           @hotel_list_cache_location = response["HotelListResponse"]["cacheLocation"]
  #         end
  #       rescue HTTParty::Error => e
  #         @error_response = e.message
  #       end
  #     else
  #       @hotels_list    = []
  #       @error_response = "You haven't selected any destinations"
  #     end
  #   else
  #     @hotels_list    = []
  #     @error_response = "You don't have any credits"
  #   end
  # end


end
