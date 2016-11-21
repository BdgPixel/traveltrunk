class CreatePlaces < ActiveRecord::Migration
  def change
    create_table :places do |t|
      t.string :place_id
      t.string :place_name
      t.string :country_id
      t.string :region_id
      t.string :city_id
      t.string :country_name

      t.timestamps null: false
    end
  end
end
