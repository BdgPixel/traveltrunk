class ReservationMailer < ApplicationMailer
  helper DealsHelper

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
end
