module Expedia
  class Hotels
    attr_accessor :current_user

    def self.current_user=(current_user)
      @current_user = current_user
    end

    def self.current_user
      @current_user
    end

    def self.set_session_customer_id=(session_)
      @customer_session_id = session_
    end

    def self.session_customer_id
      @customer_session_id
    end

    def self.set_request_headers=(request)
      @customer_ip = request[:customer_ip]
      @customer_user_agent = request[:customer_user_agent]
    end

    def self.request_headers
      @customer_ip
      @customer_user_agent
    end

    def self.global_api_params_hash
      api_key = ENV['EXPEDIA_API_KEY']
      shared_secret = ENV['EXPEDIA_SHARED_SECRET']
      timestamp = Time.now.utc.to_i
      md5 = Digest::MD5.new
      md5.update [api_key, shared_secret, timestamp].join
      sig = md5.hexdigest

      config_hash = {
        'apiKey' => api_key,
        'cid' => 496147,
        'sig' => sig,
        'minorRev' => 30,
        'locale' => "en_US",
        'currencyCode' => "USD",
        'customerIpAddress' => @customer_ip,
        'customerUserAgent' => @customer_user_agent
      }

      merge_config_hash = config_hash.merge('customerSessionId' => session_customer_id)
    end

    def self.response_result(*args)
      args.each do |arg|
        {
          welcome_state: arg[:welcome_state],
          response: arg[:response],
          customer_session_id: arg[:customer_session_id],
          num_of_hotel: arg[:num_of_hotel] || 0,
          num_of_page: arg[:num_of_page] || 0,
          error_response: {
            is_error: arg[:is_error],
            message:  arg[:error_response]
          }
        }
      end
    end

    def self.list(destination = nil, group = nil)
      unless @current_user.try(:admin?)
        if destination.blank?
          @welcome_state = 'no_destination'
          @error_response = "You haven’t selected a destination yet."
          response_result(welcome_state: @welcome_state, error_response: @error_response)
        else
          if destination
            custom_params = destination.get_search_params(group)

            url = 'http://api.ean.com/ean-services/rs/hotel/v3/list?'
            xml_params = { xml: custom_params.to_xml(skip_instruct: true, root: "HotelListRequest").gsub(" ", "").gsub("\n", "") }
            url_custom_params = url + Expedia::Hotels.global_api_params_hash.merge(xml_params).to_query
            begin
              response = HTTParty.get(url_custom_params)

              if response
                if response["HotelListResponse"]["EanWsError"]
                  @error_response = response["HotelListResponse"]["EanWsError"]["presentationMessage"]

                  response_result(response: [], error_response: @error_response)
                else
                  hotels_list =
                    if response["HotelListResponse"]["HotelList"]["@size"].eql? '1'
                      [response["HotelListResponse"]["HotelList"]["HotelSummary"]]
                    else
                      response["HotelListResponse"]["HotelList"]["HotelSummary"]
                    end

                  if hotels_list.empty?
                    @error_response = "There is no hotels that match your criteria and saving credits"
                    response_result(error_response: @error_response)
                  else
                    hotels_list =
                      hotels_list.sort do |hotel_x, hotel_y|
                        hotel_y["RoomRateDetailsList"]["RoomRateDetails"]["RateInfos"]["RateInfo"]["ChargeableRateInfo"]["@total"].to_f <=> hotel_x["RoomRateDetailsList"]["RoomRateDetails"]["RateInfos"]["RateInfo"]["ChargeableRateInfo"]["@total"].to_f
                      end

                    group   = current_user.group || current_user.joined_groups.first
                    total_credit = group.present? ? (group.total_credit / 100.0) : current_user.total_credit_in_usd

                    hotel_filter = hotels_list.group_by {|el| el["RoomRateDetailsList"]["RoomRateDetails"]["RateInfos"]["RateInfo"]["ChargeableRateInfo"]["@total"].to_f.round <= total_credit ? :affordable : :notaffordable}

                    if hotel_filter[:affordable]
                      affordable = hotel_filter[:affordable].each {|k, v| k["is_notaffordable"] = false }
                    end

                    if hotel_filter[:notaffordable]
                      notaffordable = hotel_filter[:notaffordable].each {|k, v| k["is_notaffordable"] = true}
                      notaffordable = notaffordable.sort do |k,v|
                                        k["RoomRateDetailsList"]["RoomRateDetails"]["RateInfos"]["RateInfo"]["ChargeableRateInfo"]["@total"].to_f <=> v["RoomRateDetailsList"]["RoomRateDetails"]["RateInfos"]["RateInfo"]["ChargeableRateInfo"]["@total"].to_f
                                      end
                      if affordable.present?
                        notaffordable.first["first_load"] = true
                      end
                    end

                    hotels_list   = (affordable || []) + (notaffordable || [])
                    hotels_list   = hotels_list.delete_if {|hotel| hotel["thumbNailUrl"] == nil}
                    @num_of_hotel = hotels_list.size
                    @hotels_list = hotels_list.in_groups_of(3).in_groups_of(5)
                    @num_of_page = @hotels_list.size

                    response_result(response: @hotels_list, num_of_hotel: @num_of_hotel, num_of_page: @num_of_page, customer_session_id: response["HotelListResponse"]["customerSessionId"] )
                  end
                end
              else
                response_result(response: [], error_response: "Unable to get hotel list from Expedia. Please try again later")
              end
            rescue Exception => e
              if e.is_a? Errno::ECONNRESET
                response_result(response: [], error_response: 'Unable to get hotel list from Expedia. Please try again later')
              else
                response_result(response: [], error_response: "Some errors occurred. Please contact administrator or try again later.")
              end
            end
          else
            @hotels_list    = []
            @error_response = "You haven’t selected a destination yet."

            response_result(response: @hotels_list, error_response: @error_response)
          end
        end
      end
    end

    def self.list_for_guest(destination = nil, group = nil)
      if destination
        custom_params = Destination.get_session_search_hashes(destination)

        url = 'http://api.ean.com/ean-services/rs/hotel/v3/list?'
        xml_params = { xml: custom_params.to_xml(skip_instruct: true, root: "HotelListRequest").gsub(" ", "").gsub("\n", "") }
        url_custom_params = url + Expedia::Hotels.global_api_params_hash.merge(xml_params).to_query

        begin
          response = HTTParty.get(url_custom_params)

          if response
            if response["HotelListResponse"]["EanWsError"]
              @error_response = response["HotelListResponse"]["EanWsError"]["presentationMessage"]

              response_result(response: [], error_response: @error_response)
            else
              hotels_list =
                if response["HotelListResponse"]["HotelList"]["@size"].eql? '1'
                  [response["HotelListResponse"]["HotelList"]["HotelSummary"]]
                else
                  response["HotelListResponse"]["HotelList"]["HotelSummary"]
                end

              if hotels_list.empty?
                @error_response = "There is no hotels that match your criteria and saving credits"
                response_result(error_response: @error_response)
              else
                hotels_list =
                  hotels_list.sort do |hotel_x, hotel_y|
                    hotel_y["RoomRateDetailsList"]["RoomRateDetails"]["RateInfos"]["RateInfo"]["ChargeableRateInfo"]["@total"].to_f <=> hotel_x["RoomRateDetailsList"]["RoomRateDetails"]["RateInfos"]["RateInfo"]["ChargeableRateInfo"]["@total"].to_f
                  end
                @num_of_hotel = hotels_list.size
                @hotels_list = hotels_list.in_groups_of(3).in_groups_of(5)
                @num_of_page = @hotels_list.size

                response_result(response: @hotels_list, num_of_hotel: @num_of_hotel, num_of_page: @num_of_page, customer_session_id: response["HotelListResponse"]["customerSessionId"])
              end
            end
          else
            response_result(response: [], error_response: "Unable to get hotel list from Expedia. Please try again later")
          end
        rescue Exception => e
          if e.is_a? Errno::ECONNRESET
            response_result(response: [], error_response: 'Unable to get hotel list from Expedia. Please try again later')
          else
            response_result(response: [], error_response: "Some errors occurred. Please contact administrator or try again later.")
          end
        end
      else
        @hotels_list    = []
        @error_response = "You haven’t selected a destination yet."

        response_result(response: @hotels_list, error_response: @error_response)
      end
    end

    def self.information(custom_params)
      url = "http://api.ean.com/ean-services/rs/hotel/v3/info?"
      xml_params = { xml: custom_params.to_xml(skip_instruct: true, root: "HotelInformationRequest").gsub(" ", "").gsub("\n", "") }
      url_custom_params = url + Expedia::Hotels.global_api_params_hash.merge(xml_params).to_query

      begin
        response = HTTParty.get(url_custom_params)

        if response["HotelInformationResponse"]["EanWsError"]
          @hotel_information = []
          @error_response    = response["HotelInformationResponse"]["EanWsError"]["presentationMessage"]

          response_result(response: @hotel_information, error_response: @error_response)
        else
          @hotel_information = response["HotelInformationResponse"]
          response_result(response: @hotel_information)
        end
      rescue Exception  => e
        @error_response = e.message
        response_result(error_response: @error_response)
      end
    end

    def self.room_availability(room_params)
      url = "http://api.ean.com/ean-services/rs/hotel/v3/avail?"
      xml_params = { xml: room_params.to_xml(skip_instruct: true, root: "HotelRoomAvailabilityRequest").gsub(" ", "").gsub("\n", "") }
      url_room_params = url + Expedia::Hotels.global_api_params_hash.merge(xml_params).to_query

      begin
        response = HTTParty.get(url_room_params)

        if response["HotelRoomAvailabilityResponse"]["EanWsError"]
          @room_availability = []
          @error_response    = response["HotelRoomAvailabilityResponse"]["EanWsError"]["presentationMessage"]
          @category_room_message = response["HotelRoomAvailabilityResponse"]["EanWsError"]["category"]

          response_result({ error_response: @error_response, error_category_room: @category_room_message })
        else
          @room_availability = response["HotelRoomAvailabilityResponse"]
          response_result(response: @room_availability)
        end
      rescue Exception => e
         @error_response = e.message
         response_result(error_response: @error_response)
      end
    end

    def self.reservation(custom_params)
      url = "https://book.api.ean.com/ean-services/rs/hotel/v3/res?"
      xml_params = { xml: custom_params.to_xml(skip_instruct: true, root: "HotelRoomReservationRequest").gsub(" ", "").gsub("\n", "") }
      url_custom_params = url + Expedia::Hotels.global_api_params_hash.merge(xml_params).to_query

      begin
        response = HTTParty.post(url_custom_params)

        if response["HotelRoomReservationResponse"]["EanWsError"]
          @error_response = response["HotelRoomReservationResponse"]["EanWsError"]["presentationMessage"]
          @error_response << ". "
          @error_response << response["HotelRoomReservationResponse"]["EanWsError"]["verboseMessage"]

          if response["HotelRoomReservationResponse"]["EanWsError"]["category"].eql? "DATA_VALIDATION"
            response_result(error_response: response["HotelRoomReservationResponse"]["EanWsError"]["verboseMessage"], response: response["HotelRoomReservationResponse"], is_error: true)
          else
            response_result(error_response: @error_response, response: response["HotelRoomReservationResponse"], is_error: true)
          end
        else
          @reservation = response["HotelRoomReservationResponse"]
          response_result(response: @reservation)
        end
      rescue Exception => e
        @error_response = e.message
        response_result(error_response: @error_response)
      end
    end

    def self.cancel_reservation(custom_params)
      url = "http://api.ean.com/ean-services/rs/hotel/v3/cancel?"
      xml_params = { xml: custom_params.to_xml(skip_instruct: true, root: "HotelRoomCancellationRequest").gsub(" ", "").gsub("\n", "") }
      url_custom_params = url + Expedia::Hotels.global_api_params_hash.merge(xml_params).to_query

      begin
        response = HTTParty.get(url_custom_params)

        if response["HotelRoomCancellationResponse"]["EanWsError"]
          @error_response = response["HotelRoomCancellationResponse"]["EanWsError"]
          response_result(error_response: @error_response)
        else
          cancel_response = response["HotelRoomCancellationResponse"]
          response_result(response: cancel_response)
        end
      rescue Exception => e
        @error_response = e.message
        response_result(error_response: @error_response)
      end
    end

    def self.view_itinerary(custom_params)
      url = "http://api.ean.com/ean-services/rs/hotel/v3/itin?"
      xml_params = { xml: custom_params.to_xml(skip_instruct: true, root: "HotelItineraryRequest").gsub(" ", "").gsub("\n", "") }
      url_custom_params = url + Expedia::Hotels.global_api_params_hash.merge(xml_params).to_query

      begin
        response = HTTParty.get(url_custom_params)

        if response["HotelItineraryResponse"]["EanWsError"]
          @error_response    = response["HotelItineraryResponse"]["EanWsError"]["presentationMessage"]
          response_result(error_response: @error_response)
        else
          @itinerary_response = response["HotelItineraryResponse"]
          response_result(response: @itinerary_response)
        end
      rescue Exception => e
        @error_response = e.message
        response_result(error_response: @error_response)
      end
    end
  end
end
