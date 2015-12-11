class RemoveColumnBioQuestionToProfiles < ActiveRecord::Migration
  def change
    remove_column :profiles, :favorite_place, :text
    remove_column :profiles, :vacation_moment, :text
    remove_column :profiles, :travel_destination, :text
  end
end
