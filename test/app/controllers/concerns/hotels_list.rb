module HotelsList
  include DealsHelper


  def api_params_hash
    api_key = '5fd6485clmp3oogs8gfb43p2uf'
    shared_secret = 'cjkao1pfqt0tk'
    timestamp = Time.now.utc.to_i
    md5 = Digest::MD5.new
    md5.update [api_key, shared_secret, timestamp].join
    sig = md5.hexdigest

    {
      'apiKey' => api_key,
      'cid' => 496147,
      'sig' => sig,
      'minorRev' => 30,
      'locale' => "en_US",
      'currencyCode' => "USD",
    }
  end

  def view_itinerary(custom_params)
    url = "http://api.ean.com/ean-services/rs/hotel/v3/itin?"
    expedia_api = api_params_hash
    expedia_api.delete(:numberOfResults)

    url_custom_params = url + custom_params.merge(expedia_api).to_query
    begin
      response = HTTParty.get(url_custom_params)

      if response["HotelItineraryResponse"]["EanWsError"]
        redirect_to deals_book_path(id: params[:confirmation_book][:hotel_id], rate_code: params[:confirmation_book][:rate_code], room_type_code: params[:confirmation_book][:room_type_code])
        @error_response    = response["HotelItineraryResponse"]["EanWsError"]["presentationMessage"]
      else
        @itinerary_responses = response["HotelItineraryResponse"]
      end
    rescue Exception => e
      @error_response = e.message
    end
  end

  def book_reservation(custom_params)
    url = "https://book.api.ean.com/ean-services/rs/hotel/v3/res?"
    expedia_api = api_params_hash
    expedia_api.delete(:numberOfResults)

    url_custom_params = url + custom_params.merge(expedia_api).to_query
    begin
      response = HTTParty.post(url_custom_params)
      if response["HotelRoomReservationResponse"]["EanWsError"]
        @error_response = response["HotelRoomReservationResponse"]["EanWsError"]["presentationMessage"]
        @error_response << ". "
        @error_response << response["HotelRoomReservationResponse"]["EanWsError"]["verboseMessage"]
      else
        @reservation = response["HotelRoomReservationResponse"]
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
    url = "http://api.ean.com/ean-services/rs/hotel/v3/avail?"
    xml_params = { xml: room_params.to_xml(skip_instruct: true, root: "HotelRoomAvailabilityRequest").gsub(" ", "").gsub("\n", "") }
    url_room_params = url + api_params_hash.merge(xml_params).to_query

    begin
      response = HTTParty.get(url_room_params)

      if response["HotelRoomAvailabilityResponse"]["EanWsError"]
        @room_availability = []
        @error_response    = response["HotelRoomAvailabilityResponse"]["EanWsError"]["presentationMessage"]
        @category_room_message = response["HotelRoomAvailabilityResponse"]["EanWsError"]["category"]

      else
        @room_availability = response["HotelRoomAvailabilityResponse"]
      end
    rescue Exception => e
       @error_response = e.message
    end
  end

  def get_hotel_information(custom_params)
    url                = "http://api.ean.com/ean-services/rs/hotel/v3/info?"
    url_custom_params  = url + custom_params.merge!(api_params_hash).to_query

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

  def get_hotels_list(destination, group)
    if current_user.profile.birth_date.blank? || current_user.bank_account.blank?
      @welcome_state = 'no_profile'
      @error_response = ''
    elsif destination.blank?
      @welcome_state = 'no_destination'
      @error_response = "You haven’t selected a destination yet."
    else

      if destination
        custom_params = destination.get_search_params(group)
        destinationable = destination.destinationable
        total_credit = destinationable.total_credit / 100.0

        if total_credit > 0
          url = 'http://api.ean.com/ean-services/rs/hotel/v3/list?'
          xml_params = { xml: custom_params.to_xml(skip_instruct: true, root: "HotelListRequest").gsub(" ", "").gsub("\n", "") }
          url_custom_params = url + api_params_hash.merge(xml_params).to_query

          begin
            response = HTTParty.get(url_custom_params)

            if response["HotelListResponse"]["EanWsError"]
              @hotels_list    = []
              @error_response = response["HotelListResponse"]["EanWsError"]["presentationMessage"]
            else
              hotels_list = response["HotelListResponse"]["HotelList"]["HotelSummary"].select do |hotel|
                hotel["RoomRateDetailsList"]["RoomRateDetails"]["RateInfos"]["RateInfo"]["ChargeableRateInfo"]["@total"].to_f <= total_credit
              end

              if hotels_list.empty?
                @error_response = "There are no hotels that match your criteria and saving credits"
              else
                hotels_list =
                  hotels_list.sort do |hotel_x, hotel_y|
                    hotel_y["RoomRateDetailsList"]["RoomRateDetails"]["RateInfos"]["RateInfo"]["ChargeableRateInfo"]["@total"].to_f <=> hotel_x["RoomRateDetailsList"]["RoomRateDetails"]["RateInfos"]["RateInfo"]["ChargeableRateInfo"]["@total"].to_f
                  end

                @num_of_hotels = hotels_list.size
                @hotels_list = hotels_list.in_groups_of(3).in_groups_of(5)
                binding.pry
                @num_of_pages = @hotels_list.size
              end
            end

          rescue Exception => e
            @hotels_list    = []
            @error_response = e.message
          end
        else
          @hotels_list    = []
          @error_response = "You don't have any credits."
        end

      else
        @hotels_list    = []
        @error_response = "You haven’t selected a destination yet."
      end
    end
  end

end
