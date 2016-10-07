class AddNumberOfAdultToDestinations < ActiveRecord::Migration
  def change
    add_column :destinations, :number_of_adult, :integer
  end
end
