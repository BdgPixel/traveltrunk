class DealsController < ApplicationController
  require "htmlentities"
  include HotelsList

  before_action :create_destination, only: [:search]
  before_action :check_like,         only: [:like]
  before_action :authenticate_user!

  skip_before_filter :verify_authenticity_token, only: [:update_credit]

  def index
    @destination = current_user.destination
    if @destination
      new_arrival_date = Date.today

      if @destination.arrival_date < new_arrival_date
        @destination.departure_date = new_arrival_date + (@destination.departure_date - @destination.arrival_date).to_i
        @destination.arrival_date = new_arrival_date
      end
    end

    if request.xhr?
      set_search_data
      respond_to :js
    end
  end

  def search; end

  def show
    expedia_params_hash = { hotelId: params[:id] }
    get_hotel_information(expedia_params_hash)
  end

  def book
    room_params_hash = current_user.expedia_room_params(params[:id], params[:rate_code], params[:room_type_code])

    if request.xhr?
      get_room_availability(room_params_hash)
      respond_to :js
    end
  end

  def create_book
    current_destination = current_user.destination.get_search_params

    xml_string =
      "<HotelRoomReservationRequest>
        <hotelId>#{params[:confirmation_book][:hotel_id]}</hotelId>
        <arrivalDate>#{current_destination[:arrivalDate]}</arrivalDate>
        <departureDate>#{current_destination[:departureDate]}</departureDate>
        <supplierType>E</supplierType>
        <rateKey>#{params[:confirmation_book][:rate_key]}</rateKey>
        <roomTypeCode>#{params[:confirmation_book][:room_type_code]}</roomTypeCode>
        <rateCode>#{params[:confirmation_book][:rate_code]}</rateCode>
        <chargeableRate>#{params[:confirmation_book][:total]}</chargeableRate>
        <RoomGroup>
            <Room>
                <numberOfAdults>1</numberOfAdults>
                <firstName>test</firstName>
                <lastName>tester</lastName>
                <bedTypeId>#{params[:confirmation_book][:bed_type].split(' ').join(',')}</bedTypeId>
                <smokingPreference>#{params[:confirmation_book][:smoking_preferences]}</smokingPreference>
            </Room>
        </RoomGroup>
        <ReservationInfo>
            <email>#{current_user.email}</email>
            <firstName>#{current_user.profile.first_name}</firstName>
            <lastName>#{current_user.profile.last_name}</lastName>
            <homePhone>2145370159</homePhone>
            <workPhone>2145370159</workPhone>
            <creditCardType>CA</creditCardType>
            <creditCardNumber>5401999999999999</creditCardNumber>
            <creditCardIdentifier>123</creditCardIdentifier>
            <creditCardExpirationMonth>11</creditCardExpirationMonth>
            <creditCardExpirationYear>2017</creditCardExpirationYear>
        </ReservationInfo>
        <AddressInfo>
            <address1>travelnow</address1>
            <city>#{current_user.profile.city}</city>
            <stateProvinceCode>#{current_user.profile.state}</stateProvinceCode>
            <countryCode>#{current_user.profile.country_code}</countryCode>
            <postalCode>#{current_user.profile.postal_code}</postalCode>
        </AddressInfo>
    </HotelRoomReservationRequest>"

    xml_params =  { xml: xml_string.gsub(" ", "").gsub("\n", "") }

    book_reservation(xml_params)

    if !@error_response
      total_credit = current_user.total_credit - (params[:confirmation_book][:total].to_f * 100).to_i
      # current_user.update_attributes(total_credit: total_credit)
      arrival_date = Date.strptime(@reservation["arrivalDate"], "%m/%d/%Y")
      departure_date = Date.strptime(@reservation["departureDate"], "%m/%d/%Y")

      user = User.find current_user.id
      user.total_credit = total_credit
      user.save(validate: false)

      reservation_params = {
        itinerary: @reservation["itineraryId"],
        confirmation_number: @reservation["confirmationNumbers"],
        hotel_name: @reservation["hotelName"],
        hotel_address: @reservation["hotelAddress"],
        city: @reservation["hotelCity"],
        country_code: @reservation["hotelCountryCode"],
        postal_code: @reservation["hotelPostalCode"],
        number_of_room: @reservation["numberOfRoomsBooked"],
        room_description: @reservation["roomDescription"],
        number_of_adult: @reservation["RateInfos"]["RateInfo"]["RoomGroup"]["Room"]["numberOfAdults"],
        total: @reservation["RateInfos"]["RateInfo"]["ChargeableRateInfo"]["@total"].to_f * 100.0,
        arrival_date: arrival_date,
        departure_date: departure_date
      }
      reservation = current_user.reservations.new(reservation_params)

      reservation.save
      redirect_to deals_thank_you_page_path, notice: "Booking success"

      # respond_to do |format|
      #   if reservation.save
      #     # ReservationMailer.reservation_created(@reservation, current_user.id).deliver_now
      #     format.html { redirect_to deals_thank_you_page_path, notice: "Booking success" }
      #   end
      # end
      # binding.pry
    end
  end

  def update_credit
    begin
      amount_in_cents = (params[:update_credit][:amount].to_f * 100).to_i
      charge= Stripe::Charge.create(
        :amount => amount_in_cents,
        :currency => "usd",
        :source => {
          number: params[:update_credit][:card_number],
          exp_month: params[:update_credit][:exp_month],
          exp_year: params[:update_credit][:exp_year],
          object: 'card'
        },
        :description => "Add to savings"
      )

      if charge.paid
        transaction = current_user.transactions.new(amount: charge.amount, transaction_type: 'deposit')

        if transaction.save
          total_credit = current_user.total_credit + amount_in_cents
          current_user.update_attributes(total_credit: total_credit)
          @user_total_credit = current_user.total_credit / 100.0

          StripeMailer.payment_succeed(current_user.id, transaction.amount).deliver_now

          @transaction_amount = transaction.amount / 100.0
          current_user.create_activity key: "payment.manual", owner: current_user,
            recipient: current_user, parameters: { amount: @transaction_amount, total_credit: @user_total_credit }
        end
      end

    rescue Stripe::CardError => e
      @error_response = e.message
    end
  end

  def thank_you_page
    # yuhuu
    @reservation = current_user.reservations.first
  end

  def room_availability
    if request.xhr?

      room_params_hash = current_user.expedia_room_params(params[:id])
      get_room_availability(room_params_hash)
      # get_room_availability
      # get_room_images({ hotelId: params[:id] })
      respond_to :js
    end
  end

  def room_images
    if request.xhr?
      searchParams     = current_user.get_current_destination
      hotel_id_hash = { hotelId: params[:id] }

      get_room_images(hotel_id_hash)

      respond_to do |format|
        format.js { render :reload_image }
      end
    end
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
    arrival_date = Date.strptime(destination_params[:arrival_date], "%m/%d/%Y")
    departure_date = Date.strptime(destination_params[:departure_date], "%m/%d/%Y")
    custom_params = destination_params
    custom_params.merge!({
      arrival_date:   arrival_date,
      departure_date: departure_date
    })

    if destination
      # binding.pry
      destination.update(custom_params)
    else
      destination = current_user.build_destination(custom_params)
      destination.save
    end
    set_search_data
  end

=begin
  def set_hotel(custom_params, params_cache = nil, type_list = nil)
    url =
      if type_list
        "http://api.ean.com/ean-services/rs/hotel/v3/info"
      else
        "http://api.ean.com/ean-services/rs/hotel/v3/list"
      end

    if custom_params
      params_api = {
        cid:      55505,
        minorRev: 30,
        apiKey:   "5fd6485clmp3oogs8gfb43p2uf",
        locale:       "en_US",
        currencyCode: "USD",
        supplierType: "E"
      }

      if type_list
        custom_params = custom_params.merge!(params_api)
        response = HTTParty.get(url + "?" + custom_params.to_query)
        @hotel_information = response["HotelInformationResponse"]
        @like = Like.find_by(hotel_id: params[:hotelId], user_id: current_user)
        @members_liked = User.joins(:likes, :joined_groups).where("likes.hotel_id = ? AND groups.user_id = ?", params[:hotelId], current_user)
        # yuhuu
      else
        if params_cache
          custom_params = params_api.merge!(params_cache)
          response = HTTParty.get(url + "?" + custom_params.to_query)
          @params_cache = params_cache
        else
          custom_params = custom_params.merge!(params_api)
          response = HTTParty.get(url + "?" + custom_params.to_query)
        end

        response.code
        response.message

        @hotels_list = response["HotelListResponse"]["HotelList"]["HotelSummary"]

        @hotel_list_cache_key = response["HotelListResponse"]["cacheKey"]
        @hotel_list_cache_location = response["HotelListResponse"]["cacheLocation"]

        @hotel_ids = response["HotelListResponse"]["HotelList"]["HotelSummary"].map { |hotel| hotel["hotelId"] }
        @like_ids = Like.where(hotel_id: @hotel_ids, user_id: current_user.id).pluck(:hotel_id)
      end

    end
  end
=end

  private
    def set_search_data
      if @destination = current_user.destination
        @searchParams = @destination.get_search_params
      end
      @page = params[:page].to_i + 1
      params_cache = { cacheKey: params[:cache_key], cacheLocation: params[:cache_location] } if params[:cache_key] && params[:cache_location]
      # set_hotel(@searchParams, params_cache)
      get_hotels_list(@searchParams, params_cache)
    end

    def check_like
      @like = Like.find_by(hotel_id: params[:id], user_id: current_user.id)
    end

    def destination_params
      params.require(:search_deals).permit(:destination_string, :city, :state_province_code, :country_code, :latitude, :longitude, :arrival_date, :departure_date, :postal_code)
    end
end
