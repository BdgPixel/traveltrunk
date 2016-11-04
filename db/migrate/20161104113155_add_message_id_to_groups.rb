class AddMessageIdToGroups < ActiveRecord::Migration
  def change
    add_reference :groups, :message, index: true, foreign_key: true
  end
end
