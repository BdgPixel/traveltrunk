class DealsController < ApplicationController
  require "htmlentities"
  include ExceptionErrorResponse

  before_action :check_like, only: [:like]
  before_action :authenticate_user!, except: [:search, :show, :room_availability, :create_credit,
    :confirmation_page]
  before_action :get_group, only: [:index, :search, :show, :room_availability, :create_book,
    :update_credit]
  before_action :get_destination, only: [:index, :search, :create_book, :room_availability]
  before_action :update_arrival_and_departure_date, only: [:index, :create_book, :room_availability]
  before_action :create_destination, only: [:search]
  before_action :check_address, only: [:create_book]
  before_action :set_hotel, only: [:show, :room_availability, :create_book, :confirmation_page]

  skip_before_filter :verify_authenticity_token, only: [:update_credit]

  def index
    current_user.build_profile unless current_user.profile
    @bank_account = current_user.bank_account || current_user.build_bank_account
    
    if request.xhr?
      set_search_data
      respond_to :js
    end
  end

  def search
    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    expedia_params_hash = { hotelId: params[:id] }
    @terms_and_conditions_url = "http://travel.ian.com/index.jsp?pageName=userAgreement&locale=en_US&cid=5505"

    @votes = Like.where(hotel_id: params[:id])
    @hotel_information = Expedia::Hotels.information(expedia_params_hash).first[:response]
    redirect_to deals_url, notice: 'A problem occured when request hotel details information to expedia.
      Please try again later' unless @hotel_information.present?
  end

  def book
    room_params_hash = current_user.expedia_room_params(params[:id], params[:rate_code], params[:room_type_code])

    if request.xhr?
      room_response = Expedia::Hotels.room_availability(room_params_hash).first

      @room_availability = room_response[:response]
      @error_category_room_message = room_response[:category_room]
      @error_response = room_response[:error_response]
      respond_to :js
    end
  end

  def create_book
    total_credit = (@group ? @group.total_credit : current_user.total_credit) / 100.0
    hotel_price = params[:confirmation_book][:total].to_f

    if total_credit < hotel_price
      redirect_to deals_show_url(params[:confirmation_book][:hotel_id]), notice: "You don't have enough credits to book that room"
    else
      current_destination = @destination.get_search_params(@group)

      number_of_adults = @group ? (@group.members.size + 1) : 1

      bed_type = params[:confirmation_book][:bed_type].nil? ? "" : params[:confirmation_book][:bed_type].split(' ').join(',')

      smoking_preferences = params[:confirmation_book][:smoking_preferences].nil? ? "" : params[:confirmation_book][:smoking_preferences]

      affiliateConfirmationId = SecureRandom.uuid

      reservation_hash = {
        hotelId: params[:confirmation_book][:hotel_id],
        arrivalDate: current_destination[:arrivalDate],
        departureDate: current_destination[:departureDate],
        supplierType: "E",
        rateKey: params[:confirmation_book][:rate_key],
        roomTypeCode: params[:confirmation_book][:room_type_code],
        rateCode: params[:confirmation_book][:rate_code],
        chargeableRate: params[:confirmation_book][:total],
        affiliateConfirmationId: affiliateConfirmationId,
        RoomGroup: {
          Room: {
            numberOfAdults: number_of_adults.to_s,
            firstName: "test",
            lastName: "tester",
            bedTypeId: bed_type,
            smokingPreference: smoking_preferences
          }
        },
        ReservationInfo: {
          email: current_user.email,
          firstName: current_user.profile.first_name,
          lastName: current_user.profile.last_name,
          homePhone: "2145370159",
          workPhone: "2145370159",
          creditCardType: "CA",
          creditCardNumber: "5401999999999999",
          creditCardIdentifier: "123",
          creditCardExpirationMonth: "11",
          creditCardExpirationYear: "2017"
        },
        AddressInfo: {
          address1: "travelnow",
          city: (current_user.profile.city || ""),
          stateProvinceCode: (current_user.profile.state || ""),
          countryCode: (current_user.profile.country_code || ""),
          postalCode: (current_user.profile.postal_code || "")
        },
      }

      reservation_response = Expedia::Hotels.reservation(reservation_hash).first
      @reservation = reservation_response[:response]
      @error_response = reservation_response[:error_response]

      if !@error_response
        arrival_date = Date.strptime(@reservation["arrivalDate"], "%m/%d/%Y")
        departure_date = Date.strptime(@reservation["departureDate"], "%m/%d/%Y")
        reservation_params = set_reservation_params(@reservation, arrival_date, departure_date)

        if @group
          members = @group.members.to_a
          members << current_user
          price_per_member = hotel_price.to_f / members.size

          price_per_member_hash = calculate_price_per_member({}, members, price_per_member, hotel_price)

          price_per_member_hash.each do |member, amount_to_charge|
            total_credit = member.total_credit - (amount_to_charge * 100).to_i
            member.total_credit = total_credit
            member.save(validate: false)

            # create reservation for each member (so it can be refunded for each member too later)
            reservation_params[:user_id] = member.id
            reservation_params[:total] = (amount_to_charge * 100).to_i
            reservation_params[:reservation_type] = 'group'

            reservation = Reservation.new(reservation_params)
            reservation.save

            @reservation_id = reservation.id
          end

          @group.destroy
        else
          total_credit = current_user.total_credit - (hotel_price * 100).to_i
          user = User.find current_user.id
          user.total_credit = total_credit
          user.save(validate: false)

          # create reservation for single user instead, if user don't have group
          reservation = current_user.reservations.new(reservation_params)
          reservation.save
          @reservation_id = reservation.id
        end

        flash[:reservation_message] = "You will receive an email containing the confirmation and reservation details. Please refer to your itinerary number and room confirmation number"

        redirect_to deals_confirmation_page_path(reservation_id: @reservation_id)
      else
        redirect_to deals_show_url(params[:confirmation_book][:hotel_id]), alert: @error_response
      end
    end
  end

  def create_book_for_guest
    current_destination = Destination.get_session_search_hashes(session[:destination])
    number_of_adults = session[:destination]['number_of_adult']

    bed_type = payment_params[:bed_type].nil? ?
      "" : payment_params[:bed_type].split(' ').join(',')

    smoking_preferences = payment_params[:smoking_preferences].nil? ? "" : payment_params[:smoking_preferences]

    affiliateConfirmationId = SecureRandom.uuid

    reservation_hash = {
      hotelId: payment_params[:hotel_id],
      arrivalDate: current_destination[:arrivalDate],
      departureDate: current_destination[:departureDate],
      supplierType: "E",
      rateKey: payment_params[:rate_key],
      roomTypeCode: payment_params[:room_type_code],
      rateCode: payment_params[:rate_code_room],
      chargeableRate: payment_params[:amount],
      affiliateConfirmationId: affiliateConfirmationId,
      RoomGroup: {
        Room: {
          numberOfAdults: number_of_adults.to_s,
          firstName: "test",
          lastName: "tester",
          bedTypeId: bed_type,
          smokingPreference: smoking_preferences
        }
      },
      ReservationInfo: {
        email: customer_params[:email_saving],
        firstName: customer_params[:first_name],
        lastName: customer_params[:last_name],
        homePhone: "2145370159",
        workPhone: "2145370159",
        creditCardType: "CA",
        creditCardNumber: "5401999999999999",
        creditCardIdentifier: "123",
        creditCardExpirationMonth: "11",
        creditCardExpirationYear: "2017"
      },
      AddressInfo: {
        address1: "travelnow",
        city: (customer_params[:city] || ""),
        stateProvinceCode: (customer_params[:state] || ""),
        countryCode: (customer_params[:country] || ""),
        postalCode: (customer_params[:zip] || "")
      },
    }

    reservation_response = Expedia::Hotels.reservation(reservation_hash).first
    @reservation = reservation_response[:response]
    @error_response = reservation_response[:error_response]

    if !@error_response
      arrival_date = Date.strptime(@reservation["arrivalDate"], "%m/%d/%Y")
      departure_date = Date.strptime(@reservation["departureDate"], "%m/%d/%Y")
      reservation_params = set_reservation_params(@reservation, arrival_date, departure_date)

      reservation = Reservation.new(reservation_params.merge(reservation_type: 'guest'))
      reservation.save
      @reservation_id = reservation.id

      flash[:reservation_message] = "You will receive an email containing the confirmation and reservation details. Please refer to your itinerary number and room confirmation number"

      redirect_to deals_confirmation_page_path(
        reservation_id: @reservation_id,
        email: customer_params[:email_saving],
        first_name: customer_params[:first_name],
        last_name: customer_params[:last_name],
      )
    else
      redirect_to deals_show_url(params[:confirmation_book][:hotel_id]), alert: @error_response
    end
  end

  def calculate_price_per_member(price_per_member_hash, members, price_per_member, hotel_price)
    more_credit_members = []
    less_credit_members = []

    members.each do |member|
      member_total_credit = member.total_credit / 100.0

      if member_total_credit >= price_per_member
        more_credit_members << member
        price_per_member_hash[member] = price_per_member
      else
        less_credit_members << member
        price_per_member_hash[member] = member_total_credit
      end
    end

    current_total_credit = price_per_member_hash.values.sum

    if current_total_credit < hotel_price
      remaining_price_per_member = (hotel_price - current_total_credit)  / more_credit_members.size
      price_per_member += remaining_price_per_member
      calculate_price_per_member(price_per_member_hash, more_credit_members, price_per_member, hotel_price)
    else
      price_per_member_hash
    end
  end

  # one time payment using authorize.net
  def create_credit
    begin
      exp_month = payment_params[:exp_month].rjust(2, '0')
      exp_year = payment_params[:exp_year][-2, 2]
      invoice = AuthorizeNetLib::Global.generate_random_id('inv')

      params_hash = payment_params.merge({ 
        exp_date: "#{exp_month}#{exp_year}",
        order: { 
          invoice: invoice,
          description: 'Add to Saving'
        }
      })

      customer_id = AuthorizeNetLib::Global.generate_random_id('cus')
      customer_params_hash = customer_params.merge(merchant_customer_id: customer_id)
      
      payment = AuthorizeNetLib::PaymentTransactions.new

      response_payment = payment.charge(params_hash, customer_params_hash)

      if response_payment.messages.resultCode.eql? 'Ok'
        create_book_for_guest
      end
    rescue => e
      error_message(e)
    end 
  end

  def update_credit
    begin
      exp_month = params[:update_credit][:exp_month].rjust(2, '0')
      exp_year = params[:update_credit][:exp_year][-2, 2]
      invoice = AuthorizeNetLib::Global.generate_random_id('inv')

      params_hash = { 
        amount: params[:update_credit][:amount],
        card_number: params[:update_credit][:card_number],
        exp_date: "#{exp_month}#{exp_year}",
        cvv: params[:update_credit][:cvv],
        order: { 
          invoice: invoice,
          description: 'Add to Saving'
        }
      }
      
      payment = AuthorizeNetLib::PaymentTransactions.new
      customer_authorize = AuthorizeNetLib::Customers.new

      customer_profile = 
        if current_user.customer
          get_customer_profile = customer_authorize.get_customer_profile(current_user.customer.customer_profile_id)
          current_user.profile.get_profile_hash(get_customer_profile)
        else
          current_user.profile.get_profile_hash
        end

      response_payment = payment.charge(params_hash, customer_profile)

      if response_payment.messages.resultCode.eql? 'Ok'
        amount_in_cents = (params[:update_credit][:amount].to_f * 100).to_i
        customer_id = current_user.customer.customer_id if current_user.customer

        transaction = current_user.transactions.new(
          amount: amount_in_cents,
          invoice_id: invoice,
          customer_id: customer_id,
          transaction_type: 'add_to_saving', 
          ref_id: response_payment.refId,
          trans_id: response_payment.transactionResponse.transId
        )

        if transaction.save
          @user_total_credit = current_user.total_credit / 100.0
          @transaction_amount = transaction.amount / 100.0

          @total_credit = 
            if @group
              @group.total_credit / 100.0
            else
              @user_total_credit
            end

          @notification_count = current_user.get_notification(false).count

          card_last_4 = response_payment.transactionResponse.accountNumber

          PaymentProcessorMailer.delay.payment_succeed(current_user.id, transaction.amount, card_last_4)
        end
      end
    rescue => e
      error_message(e)
    end
  end

  def confirmation_page
    if params[:reservation_id]
      @reservation = Reservation.find(params[:reservation_id])

      @profile = {
        email: user_signed_in? ? current_user.email : params[:email],
        first_name: user_signed_in? ? current_user.profile.first_name : params[:first_name],
        last_name: user_signed_in? ? current_user.profile.last_name : params[:last_name],
      }

      itinerary_params = { itineraryId: @reservation.itinerary, email: @profile[:email]}

      itinerary_response = Expedia::Hotels.view_itinerary(itinerary_params).first
      
      @itinerary_response = itinerary_response[:response]["Itinerary"]["HotelConfirmation"]
      @charge_able_rate_info = @itinerary_response["RateInfos"]["RateInfo"]["ChargeableRateInfo"]
      @error_response = itinerary_response[:error_response]
      @list_of_dates = (@reservation.arrival_date..@reservation.departure_date).to_a
      @list_of_dates.pop
    else
      redirect_to deals_url, notice: 'You need to provide reservation id'
    end
  end

  def room_availability
    if user_signed_in?
      @current_user_votes_count = Like.where(hotel_id: params[:id], user_id: current_user.id).count

      @total_credit =
        if @group
          @group.total_credit
        else
          current_user.total_credit
        end

      if request.xhr?
        room_params_hash = current_user.expedia_room_params(params[:id], @destination, @group)

        room_response = Expedia::Hotels.room_availability(room_params_hash).first

        @room_availability = room_response[:response]
        @first_room_image = get_first_room_image(@room_availability)

        @error_category_room_message = room_response[:category_room]
        @error_response = room_response[:error_response]
      end
    else
      if request.xhr?
        room_params_hash = expedia_room_hashes(params[:id], session[:destination], @group, )

        room_response = Expedia::Hotels.room_availability(room_params_hash).first

        @room_availability = room_response[:response]
        @first_room_image = get_first_room_image(@room_availability)

        @error_category_room_message = room_response[:category_room]
        @error_response = room_response[:error_response]
      end
    end

    respond_to :js
  end

  def like
    @hotel_id = params[:id]
    
    notice =
      if @like.present?
        @like.destroy
        'You successfully cancel vote for this hotel'
      else
        like = Like.new(hotel_id: @hotel_id, user_id: current_user.id)
        if like.save
          joined_group = current_user.joined_groups.first
          joined_group.members.each do |user|
            unless user.id.eql?(current_user.id)
              like.create_activity key: "group.like", owner: current_user,
                recipient: user, parameters: { hotel_id: @hotel_id, hotel_name: params[:hotel_name] }
            end
          end
          like.create_activity key: "group.like", owner: current_user,
            recipient: joined_group.user, parameters: { hotel_id: @hotel_id, hotel_name: params[:hotel_name] }
        end
        'You successfully vote for this hotel'
      end

    redirect_to deals_show_url(params[:id]), notice: notice
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
    arrival_date = Date.strptime(destination_params[:arrival_date], "%m/%d/%Y")
    departure_date = Date.strptime(destination_params[:departure_date], "%m/%d/%Y")
    custom_params = destination_params
    
    custom_params.merge!({
      arrival_date:   arrival_date,
      departure_date: departure_date
    })

    if user_signed_in?
      if @destination
        @destination.update(custom_params)
      else
        @destination = @destinationable.build_destination(custom_params)
        @destination.save
      end
    else
      @destination = Destination.new(custom_params)
      set_destination_to_session(@destination)
    end

    set_search_data
  end

  private
    def set_search_data
      Expedia::Hotels
      Expedia::Hotels.current_user = current_user

      @hotels_list = 
        if user_signed_in?
          Expedia::Hotels.list(@destination, @group)
        else
          Expedia::Hotels.list_without_sign_user(session[:destination], @group)
        end
    end

    def set_hotel
      if user_signed_in?
        Expedia::Hotels
        Expedia::Hotels.current_user = current_user
      end
    end

    def check_like
      @like = Like.find_by(hotel_id: params[:id], user_id: current_user.id)
    end

    def destination_params
      params.require(:search_deals).permit(:destination_string, :city, :state_province_code,
        :country_code, :latitude, :longitude, :arrival_date, :departure_date, :postal_code,
        :number_of_adult)
    end

    def payment_params
      params_require = (params[:create_credit] ? 'create_credit' : 'update_credit').to_sym
      current_params = params.require(params_require).permit(:card_number, :cvv, :exp_month, :exp_year,
        :amount, :arrival_date, :departure_date, :room_type_code, :rate_key,:bed_type, :rate_code_room)

      current_params.merge(hotel_id: params[params_require][:id])
    end

    def customer_params
      params_require = (params[:create_credit] ? 'create_credit' : 'update_credit').to_sym
      params.require(params_require).permit(:email_saving, :first_name, :last_name, :address, :city,
        :state, :zip, :country)
    end

    def get_destination
      if user_signed_in?
        @destinationable = @group || current_user
        @destination = @destinationable.destination
      end
    end

    def update_arrival_and_departure_date
      @destination.try(:update_arrival_and_departure_date)
    end

    def check_address
      unless current_user.profile.address_valid?
        redirect_to edit_profile_url, alert: "In order to book, you need to provide city, state, country code, postal code information first"
      end
    end

    def get_room_image(room_images)
      if room_images
        if room_images["@size"].eql? "1"
          room_images["RoomImage"]["url"].gsub('http', 'https')
        else
          room_images["RoomImage"].first["url"].gsub('http', 'https')
        end
      end
    end

    def get_first_room_image(room_availability)
      if room_availability
        first_room_image = nil

        if room_availability["@size"].eql? "1"
          room = room_availability["HotelRoomResponse"]
          first_room_image = get_room_image(room["RoomImages"])
        else
          room_availability["HotelRoomResponse"].uniq.each do |room|
            first_room_image = get_room_image(room["RoomImages"])
            break if first_room_image
          end
        end

        first_room_image
      end
    end

    def set_reservation_params(reservation, arrival_date, departure_date)
      reservation_params = {
        itinerary:            reservation["itineraryId"],
        confirmation_number:  reservation["confirmationNumbers"],
        hotel_name:           reservation["hotelName"],
        hotel_address:        reservation["hotelAddress"],
        city:                 reservation["hotelCity"],
        country_code:         reservation["hotelCountryCode"],
        postal_code:          reservation["hotelPostalCode"],
        number_of_room:       reservation["numberOfRoomsBooked"],
        room_description:     reservation["roomDescription"],
        number_of_adult:      reservation["RateInfos"]["RateInfo"]["RoomGroup"]["Room"]["numberOfAdults"],
        total:                (reservation["RateInfos"]["RateInfo"]["ChargeableRateInfo"]["@total"].to_f * 100.0).round,
        arrival_date:         arrival_date,
        departure_date:       departure_date
      }
    end

    def set_destination_to_session(destination)
      session[:destination] = { 
        'destination_string' => destination.destination_string,
        'city' => destination.city,
        'state_province_code' => destination.state_province_code,
        'country_code' => destination.country_code,
        'latitude' => destination.latitude,
        'longitude' => destination.longitude,
        'arrival_date' => destination.arrival_date,
        'departure_date' => destination.departure_date,
        'number_of_adult' => destination.number_of_adult
      }
    end

    def expedia_room_hashes(hotel_id, destination, group, rate_code = nil, room_type_code = nil)
      room_hash = {}
      
      if destination
        current_search = Destination.get_session_search_hashes(destination)

        room_hash[:hotelId]       = hotel_id.to_s
        room_hash[:arrivalDate]   = current_search[:arrivalDate]
        room_hash[:departureDate] = current_search[:departureDate]


        if rate_code && room_type_code
          room_hash[:rateCode]     = rate_code
          room_hash[:roomTypeCode] = room_type_code
        end

        room_hash[:includeRoomImages] = 'true'
        room_hash[:options]           = "ROOM_TYPES"
        room_hash[:includeDetails]    = 'true'

        room_hash[:RoomGroup] = {
          'Room' => {
            'numberOfAdults' => group ? group.members.size.next.to_s : '1'
          }
        }
      end

      room_hash
    end
end
