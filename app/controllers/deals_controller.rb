class DealsController < ApplicationController
  require "htmlentities"
  include HotelsList

  before_action :create_destination, only: [:search]
  before_action :check_like,         only: [:like]
  before_action :authenticate_user!

  skip_before_filter :verify_authenticity_token, only: [:update_credit]

  def index
    destinationable = current_user.group || current_user.joined_groups.first || current_user
    @destination = destinationable.destination

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
    @terms_and_conditions_url = "http://travel.ian.com/index.jsp?pageName=userAgreement&locale=en_US&cid=5505"

    @votes = Like.where(hotel_id: params[:id])
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
            numberOfAdults: "1",
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
          city: current_user.profile.city,
          stateProvinceCode: current_user.profile.state,
          countryCode: current_user.profile.country_code,
          postalCode: current_user.profile.postal_code
        },
      }

    xml_params =  { xml: reservation_hash.to_xml(skip_instruct: true, root: "HotelRoomReservationRequest").gsub(" ", "").gsub("\n", "") }

    book_reservation(xml_params)

    if !@error_response
      total_credit = current_user.total_credit - (params[:confirmation_book][:total].to_f * 100).to_i

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
        total: (@reservation["RateInfos"]["RateInfo"]["ChargeableRateInfo"]["@total"].to_f * 100.0).round,
        arrival_date: arrival_date,
        departure_date: departure_date
      }
      reservation = current_user.reservations.new(reservation_params)

      if reservation.save
        flash[:reservation_message] = "You will receive an email containing the confirmation and reservation details. Please refer to your itinerary number and room confirmation number"
        redirect_to deals_confirmation_page_path
      end

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

          StripeMailer.payment_succeed(current_user.id, transaction.amount, charge.source.last4).deliver_now

          @transaction_amount = transaction.amount / 100.0
          current_user.create_activity key: "payment.manual", owner: current_user,
            recipient: current_user, parameters: { amount: @transaction_amount, total_credit: @user_total_credit }
          @notification_count = current_user.get_notification(false).count
        end
      end

    rescue Stripe::CardError => e
      @error_response = e.message
    end
  end

  def confirmation_page
    @reservation = current_user.reservations.last
    itinerary_params = { itineraryId: @reservation.itinerary, email: current_user.email}
    view_itinerary(itinerary_params)
    @list_of_dates = (@reservation.arrival_date..@reservation.departure_date).to_a
    @list_of_dates.pop
  end

  def room_availability
    if current_user.group.present?
      @group = current_user.group
      @total_credit = current_user.group.total_credit
    elsif current_user.joined_groups.present?
      @group = current_user.joined_groups.first
      @total_credit = current_user.joined_groups.first.total_credit
    else
      @group
      # binding.pry
      @total_credit = current_user.total_credit
    end

      # @total_credit    = current_user.group ? current_user.group.total_credit : current_user.total_credit

    if request.xhr?
      room_params_hash = current_user.expedia_room_params(params[:id])
      get_room_availability(room_params_hash)

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

  # commented but will be used later
  #
  def like
    @hotel_id = params[:id]
    if @like.present?
      @like.destroy
    else
      like = Like.new(hotel_id: @hotel_id, user_id: current_user.id)
      if like.save
        joined_groups = current_user.joined_groups.first
        joined_groups.members.each do |user|
          unless user.id.eql?(current_user.id)
            like.create_activity key: "group.like", owner: current_user,
              recipient: User.find(user.id), parameters: { hotel_id: @hotel_id, hotel_name: params[:hotel_name] }
          end
          like.create_activity key: "group.like", owner: current_user,
            recipient: User.find(joined_groups.user_id), parameters: { hotel_id: @hotel_id, hotel_name: params[:hotel_name] }
        end
        redirect_to deals_show_url(params[:id])
      end
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
    arrival_date = Date.strptime(destination_params[:arrival_date], "%m/%d/%Y")
    departure_date = Date.strptime(destination_params[:departure_date], "%m/%d/%Y")
    custom_params = destination_params
    custom_params.merge!({
      arrival_date:   arrival_date,
      departure_date: departure_date
    })

    destinationable = current_user.group || current_user.joined_groups.first || current_user

    if @destination = destinationable.destination
      @destination.update(custom_params)
    else
      @destination = destinationable.build_destination(custom_params)
      @destination.save
    end

    set_search_data
  end

  private
    def set_search_data
      get_hotels_list(@destination)
    end

    def check_like
      @like = Like.find_by(hotel_id: params[:id], user_id: current_user.id)
    end

    def destination_params
      params.require(:search_deals).permit(:destination_string, :city, :state_province_code, :country_code, :latitude, :longitude, :arrival_date, :departure_date, :postal_code)
    end
end
