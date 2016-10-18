class ReservationsController < ApplicationController
  def index; end

  def detail
    if params[:reservation][:itinerary] || params[:reservation][:email]
      @reservation = Reservation.find_by(itinerary: params[:reservation][:itinerary])

      if @reservation
        itinerary_params = { itineraryId: @reservation.itinerary, email: params[:reservation][:email] }
        itinerary_response = Expedia::Hotels.view_itinerary(itinerary_params).first
        
        if itinerary_response[:error_response]
          @error_response = "Your reservation with Itinerary ID #{@reservation.itinerary} and Email #{@reservation.email} not found on Expedia"
          redirect_to reservations_url, alert: @error_response
        else
          @itinerary = itinerary_response[:response]["Itinerary"]
          @hotel_confirmation = itinerary_response[:response]["Itinerary"]["HotelConfirmation"]
          @charge_able_rate_info = @hotel_confirmation["RateInfos"]["RateInfo"]["ChargeableRateInfo"]
          @list_of_dates = (@reservation.arrival_date..@reservation.departure_date).to_a
          @list_of_dates.pop
          # binding.pry
        end
      else
        redirect_to reservations_url, alert: 'Your reservation not found on our database'
      end
    else
      redirect_to reservations_url, alert: 'Itinerary ID or Email cannot be blank'
    end
  end
end
