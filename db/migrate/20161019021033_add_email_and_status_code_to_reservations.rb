class AddEmailAndStatusCodeToReservations < ActiveRecord::Migration
  def change
    add_column :reservations, :email, :string
    add_column :reservations, :status_code, :string
  end
end
