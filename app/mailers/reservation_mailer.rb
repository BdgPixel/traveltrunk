class ReservationMailer < ApplicationMailer
  helper DealsHelper
  helper ReservationsHelper

  def reservation_created(reservation, user_id, info)
    @user = User.select(:id, :email).find user_id

    @profile = @user.profile
    @reservation = reservation
    arrival_date =  Date.strptime(@reservation['arrivalDate'], '%m/%d/%Y')
    departure_date =  Date.strptime(@reservation['departureDate'], '%m/%d/%Y')
    @list_of_dates = (arrival_date..departure_date).to_a
    @list_of_dates.pop
    @info = info
    
    mail to: @user.email, subject: 'Reservation Success'
  end

  def reservation_created_for_guest(reservation, user, info)
    @user = user
    @reservation = reservation
    arrival_date =  Date.strptime(@reservation['arrivalDate'], '%m/%d/%Y')
    departure_date =  Date.strptime(@reservation['departureDate'], '%m/%d/%Y')
    @list_of_dates = (arrival_date..departure_date).to_a
    @list_of_dates.pop
    @info = info
    
    mail to: @user[:email_saving], subject: 'Reservation Success'
  end

  def reservation_created_for_guest_based_status(reservation, user, info, status_code = nil)
    @user = user
    @reservation = reservation
    @hotel_confirmation_hash = @reservation['HotelConfirmation']
    @arrival_date =  Date.strptime(@hotel_confirmation_hash['arrivalDate'], '%m/%d/%Y')
    @departure_date =  Date.strptime(@hotel_confirmation_hash['departureDate'], '%m/%d/%Y')
    @list_of_dates = (@arrival_date..@departure_date).to_a
    @list_of_dates.pop
    @info = info
    
    mail to: @user[:email_saving], subject: 'Reservation Success'
  end
end
