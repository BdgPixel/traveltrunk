# == Schema Information
#
# Table name: reservations
#
#  id                  :integer          not null, primary key
#  user_id             :integer
#  itinerary           :string
#  confirmation_number :string
#  arrival_date        :date
#  departure_date      :date
#  hotel_name          :string
#  hotel_address       :text
#  city                :string
#  country_code        :string
#  postal_code         :string
#  number_of_room      :string
#  room_description    :text
#  number_of_adult     :integer
#  total               :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  reservation_type    :string           default("person")
#  status              :string           default("reserved")
#  email               :string
#  status_code         :string
#

class Reservation < ActiveRecord::Base
  belongs_to :user

  paginates_per 10

  def self.get_reservation_list
    self.select(:id, :user_id, :hotel_name, :city, :total, :reservation_type, :status, 
      :email, :created_at).order(created_at: :desc)
  end

  def self.check_pending_reservations
    reservations = self.where(status_code: 'PS').distinct('itinerary, email')

    reservations.each do |reservation|
      itinerary_params = { itineraryId: reservation.itinerary, email: reservation.email }
      itinerary_response = Expedia::Hotels.view_itinerary(itinerary_params).first

      if itinerary_response[:error_response]
        puts itinerary_response[:error_response]
      else
        room_reservation = itinerary_response[:response]["Itinerary"]
        status_code = room_reservation['HotelConfirmation']['status']

        unless reservation.status_code.eql? status_code
          status = 
            case status_code
            when 'CF' then 'reserved'
            when 'PS' then 'pending'
            when 'ER' then 'failed'
            when 'CX' then 'cancelled'
            end

          if reservation.reservation_type.eql? 'group'
            related_reservations = self.where(itinerary: reservation.itinerary)
            puts related_reservations.to_json

            related_reservations.each do |related_reservation|
              ReservationMailer.status_changes_notification(related_reservation.user.email,
                related_reservation, status_code).deliver_now
            end

            related_reservations.update_all(status_code: status_code, status: status)
          else
            ReservationMailer.status_changes_notification(reservation.email,
              reservation, status_code).deliver_now
            
            reservation.update(status_code: status_code, status: status)
          end
        end
      end
    end
  end
end
