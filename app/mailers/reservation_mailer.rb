class ReservationMailer < ApplicationMailer
  helper DealsHelper
  helper ReservationsHelper

  def reservation_created(reservation, user, info)
    @user = user

    @profile = @user.profile
    @reservation = reservation
    arrival_date =  Date.strptime(@reservation['arrivalDate'], '%m/%d/%Y')
    departure_date =  Date.strptime(@reservation['departureDate'], '%m/%d/%Y')
    @list_of_dates = (arrival_date..departure_date).to_a
    @list_of_dates.pop
    @info = info

    mail to: @user.email, subject: 'Reservation Success'
  end

  def pending_reservation(reservation, user, info)
    @user = user

    @profile = @user.profile
    @reservation = reservation
    @hotel_confirmation_hash = @reservation['HotelConfirmation']
    @arrival_date =  Date.strptime(@hotel_confirmation_hash['arrivalDate'], '%m/%d/%Y')
    @departure_date =  Date.strptime(@hotel_confirmation_hash['departureDate'], '%m/%d/%Y')
    @list_of_dates = (@arrival_date..@departure_date).to_a
    @list_of_dates.pop
    @info = info

    mail to: @user.email, subject: 'Reservation is Pending'
  end

  def reservation_created_guest(reservation, user, info)
    @user = user
    @reservation = reservation
    arrival_date =  Date.strptime(@reservation['arrivalDate'], '%m/%d/%Y')
    departure_date =  Date.strptime(@reservation['departureDate'], '%m/%d/%Y')
    @list_of_dates = (arrival_date..departure_date).to_a
    @list_of_dates.pop
    @info = info

    mail to: @user[:email_saving], subject: 'Reservation Success'
  end

  def pending_reservation_guest(reservation, user, info, status_code = nil)
    @user = user
    @reservation = reservation
    @hotel_confirmation_hash = @reservation['HotelConfirmation']
    @arrival_date =  Date.strptime(@hotel_confirmation_hash['arrivalDate'], '%m/%d/%Y')
    @departure_date =  Date.strptime(@hotel_confirmation_hash['departureDate'], '%m/%d/%Y')
    @list_of_dates = (@arrival_date..@departure_date).to_a
    @list_of_dates.pop
    @info = info

    mail to: @user[:email_saving], subject: 'Reservation is Pending'
  end

  def status_changes_notification(recipient, reservation, status_code)
    @reservation = reservation
    @status_code = status_code

    mail to: recipient, subject: 'Reservation Status Notification'
  end
end
