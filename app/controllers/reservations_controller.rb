class ReservationsController < ApplicationController
  def index; end

  def detail
    if params[:reservation][:itinerary_id] || params[:reservation][:email]
      @reservation = Reservation.find_by(itinerary: params[:reservation][:itinerary_id])

      if @reservation
        itinerary_params = { itineraryId: @reservation.itinerary, email: params[:reservation][:email] }
        itinerary_response = Expedia::Hotels.view_itinerary(itinerary_params).first

        if itinerary_response[:error_response]
          @error_response = "Your reservation with Itinerary ID #{@reservation.itinerary} and Email #{params[:reservation][:email]} not found on Expedia"
          redirect_to reservations_url, alert: @error_response
        else
          @itinerary = itinerary_response[:response]["Itinerary"]
          @hotel_confirmation = itinerary_response[:response]["Itinerary"]["HotelConfirmation"]
          @charge_able_rate_info = @hotel_confirmation["RateInfos"]["RateInfo"]["ChargeableRateInfo"]
          @list_of_dates = (@reservation.arrival_date..@reservation.departure_date).to_a
          @list_of_dates.pop

          @reservation.update(status_code: @hotel_confirmation["status"])
        end
      else
        redirect_to reservations_url, alert: 'Your reservation not found on our database'
      end
    else
      redirect_to reservations_url, alert: 'Itinerary ID or Email cannot be blank'
    end
  end

  def cancel
    cancel_params = params.require(:cancel_reservation).permit(:itinerary_id, :email, :reason,
        :confirmation_number)

    request_hash = {
      itineraryId: cancel_params[:itinerary_id],
      confirmationNumber: cancel_params[:confirmation_number],
      email: cancel_params[:email],
      reason: cancel_params[:reason],
      apiExperience: 'PARTNER_AFFILIATE'
    }

    cancel_reservation_response = Expedia::Hotels.cancel_reservation(request_hash).first
    @cancel_reservation = cancel_reservation_response[:response]
    @error_response = cancel_reservation_response[:error_response]

    unless @error_response
      itinerary_params = { itineraryId: cancel_params[:itinerary_id], email: cancel_params[:email] }
      itinerary_response = Expedia::Hotels.view_itinerary(itinerary_params).first
      @status_code = itinerary_response[:response]["Itinerary"]["HotelConfirmation"]["status"]

      reservation = Reservation.find_by(itinerary: cancel_params[:itinerary_id])
      reservation.update(status_code: @status_code)
    end

    respond_to { |format| format.js }
  end
end
