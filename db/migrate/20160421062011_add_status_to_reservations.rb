class AddStatusToReservations < ActiveRecord::Migration
  def change
    add_column :reservations, :status, :string
  end
end
