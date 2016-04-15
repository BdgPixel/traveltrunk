class AddColumnToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :home_airport, :text
    add_column :profiles, :place_to_visit, :text
  end
end
