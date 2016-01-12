module Expedia
  class Hotels
    attr_accessor :current_user

    def self.current_user=(current_user)
      @current_user = current_user
    end

    def self.current_user
      @current_user
    end

    def self.global_api_params_hash
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

    def initialize(current_user_params)
      # @current_user = Expedia::current_user(current_user_params)
      # puts 'asdf'
    end

    def self.list(destination = nil, group = nil)
      if @current_user.profile.birth_date.blank? || @current_user.bank_account.blank?
        @welcome_state = 'no_profile'
        @error_response = ''
        response_result(welcome_state: @welcome_state, error_response: @error_response)
      elsif destination.blank?
        @welcome_state = 'no_destination'
        @error_response = "You haven’t selected a destination yet."
        response_result(welcome_state: @welcome_state, error_response: @error_response)
      else
        if destination
          custom_params = destination.get_search_params(group)
          destinationable = destination.destinationable
          total_credit = destinationable.total_credit / 100.0

          if total_credit > 0
            url = 'http://api.ean.com/ean-services/rs/hotel/v3/list?'
            xml_params = { xml: custom_params.to_xml(skip_instruct: true, root: "HotelListRequest").gsub(" ", "").gsub("\n", "") }
            url_custom_params = url + Expedia::Hotels.global_api_params_hash.merge(xml_params).to_query

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

                  @num_of_hotel = hotels_list.size
                  @hotels_list = hotels_list.in_groups_of(3).in_groups_of(5)
                  @num_of_page = @hotels_list.size

                  response_result(response: @hotels_list, num_of_hotel: @num_of_hotel, num_of_page: @num_of_page )
                end
              end

            rescue Exception => e
              @hotels_list    = []
              @error_response = e.message
              response_result(response: @hotels_list, error_response: @error_response)
            end
          else
            @hotels_list    = []
            @error_response = "You don't have any credits."
            response_result(response: @hotels_list, error_response: @error_response)
          end

        else
          @hotels_list    = []
          @error_response = "You haven’t selected a destination yet."
          response_result(response: @hotels_list, error_response: @error_response)
        end
      end


    end

    def self.response_result(*args)
      args.each do |arg|
        {
          welcome_state: arg[:welcome_state],
          response: arg[:response],
          num_of_hotel: arg[:num_of_hotel] || 0,
          num_of_page: arg[:num_of_page] || 0,
          error_response: {
            message:  arg[:error_response]
          }
        }
      end
    end

  end

end
