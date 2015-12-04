class AddBioQuestionToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :favorite_place, :text
    add_column :profiles, :vacation_moment, :text
    add_column :profiles, :travel_destination, :text
  end
end
