class DealsController < ApplicationController
  require "htmlentities"
  include ExceptionErrorResponse

  before_action :check_like, only: [:like]
  before_action :authenticate_user!
  before_action :get_group, only: [:index, :search, :show, :room_availability, :create_book, :update_credit]
  before_action :get_destination, only: [:index, :search, :create_book, :room_availability]
  before_action :create_destination, only: [:search]
  before_action :check_address, only: [:create_book]
  before_action :set_hotel, only: [:show, :room_availability, :create_book, :confirmation_page]

  skip_before_filter :verify_authenticity_token, only: [:update_credit]

  def index
    if @destination
      new_arrival_date = Time.zone.now.to_date

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
    @terms_and_conditions_url = "http://travel.ian.com/index.jsp?pageName=userAgreement&locale=en_US&cid=5505"

    @votes = Like.where(hotel_id: params[:id])
    @hotel_information = Expedia::Hotels.information(expedia_params_hash).first[:response]

    redirect_to deals_url, notice: 'A problem occured when request hotel details information to expedia. Please try again later' unless @hotel_information.present?
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

      number_of_adults =
        if @group
          @group.members.size + 1
        else
          1
        end

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

            # add to reservation
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

          # add to reservation if not group
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

  # Charge using authorizenet
  def update_credit
    begin
      exp_month = params[:update_credit][:exp_month].rjust(2, '0')
      exp_year = params[:update_credit][:exp_year][-2, 2]
      invoice = AuthorizeNetLib::Global.generate_random_id('inv')

      params_hash = {
        amount: params[:update_credit][:amount].to_f,
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

          PaymentProcessorMailer.payment_succeed(current_user.id, transaction.amount, card_last_4).deliver_now
        end
      end
    rescue => e
      error_message(e)
      # if e.is_a?(AuthorizeNetLib::RescueErrorsResponse)
      #   @error_response = 
      #     if e.error_message[:response_error_text]
      #       "#{e.error_message[:response_message]} #{e.error_message[:response_error_text]}"
      #     else
      #       e.error_message[:response_message].split('-').last.strip
      #     end
          
     
      # else
      #   logger.error e.message
      #   e.backtrace.each { |line| logger.error line }
      # end

      # false
    end
  end

  def confirmation_page
    if params[:reservation_id]
      @reservation = Reservation.find(params[:reservation_id])
      itinerary_params = { itineraryId: @reservation.itinerary, email: current_user.email}

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
      @error_category_room_message = room_response[:category_room]
      @error_response = room_response[:error_response]
      respond_to :js
    end
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

    if @destination
      @destination.update(custom_params)
    else
      @destination = @destinationable.build_destination(custom_params)
      @destination.save
    end

    set_search_data
  end

  private
    def set_search_data
      Expedia::Hotels
      Expedia::Hotels.current_user = current_user
      @hotels_list = Expedia::Hotels.list(@destination, @group)
    end

    def set_hotel
      Expedia::Hotels
      Expedia::Hotels.current_user = current_user
    end

    def check_like
      @like = Like.find_by(hotel_id: params[:id], user_id: current_user.id)
    end

    def destination_params
      params.require(:search_deals).permit(:destination_string, :city, :state_province_code, :country_code, :latitude, :longitude, :arrival_date, :departure_date, :postal_code)
    end

    def get_destination
      @destinationable = @group || current_user
      @destination = @destinationable.destination
    end

    def check_address
      unless current_user.profile.address_valid?
        redirect_to edit_profile_url, alert: "In order to book, you need to provide city, state, country code, postal code information first"
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
end
