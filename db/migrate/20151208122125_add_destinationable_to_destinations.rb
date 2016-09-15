class AddDestinationableToDestinations < ActiveRecord::Migration
  def change
    add_reference :destinations, :destinationable, polymorphic: true, index: { name: 'index_destination_polymorphic' }
  end
end
