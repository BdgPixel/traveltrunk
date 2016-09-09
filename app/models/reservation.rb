class Reservation < ActiveRecord::Base
  belongs_to :user

  paginates_per 10

  def self.get_reservation_list
    self.select(:id, :user_id, :hotel_name, :city, :total, :reservation_type, :status,
      :created_at).order(created_at: :desc)
  end
end
