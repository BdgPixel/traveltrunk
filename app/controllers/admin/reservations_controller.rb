class Admin::ReservationsController < Admin::ApplicationController
  before_action :set_reservation, only: :update
  before_action :authenticate_user!

  def index
    @reservations = Reservation.get_reservation_list.page params[:page]
  end

  def update
    @reservation.update_attributes(status: 'refunded')
    user = @reservation.user
    user_total_credit = user.total_credit + @reservation.total
    user.update_attributes(total_credit: user_total_credit)

    redirect_to admin_reservations_url, notice: 'Reservation has been refunded'
  end

  private
    def set_reservation
      @reservation = Reservation.find params[:id]
    end
end
