class ReservationMailer < ApplicationMailer
  def reservation_created(reservation)
    user = User.select(:id, :email).find user_id

    @profile = user.profile
    @reservation = reservation

    mail to: user.email, subject: 'TravelTrunk - Reservation Created'
  end
end
