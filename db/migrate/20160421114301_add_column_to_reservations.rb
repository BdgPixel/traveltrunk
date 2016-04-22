class AddColumnToReservations < ActiveRecord::Migration
  def change
    add_column :reservations, :reservation_type, :string, default: 'person'
    add_column :reservations, :status, :string, default: 'reserved'
  end
end
