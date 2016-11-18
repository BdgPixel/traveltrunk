class AddRateCodeAndRoomTypeCodeToLikes < ActiveRecord::Migration
  def change
    add_column :likes, :rate_code, :string
    add_column :likes, :room_type_code, :string
  end
end
