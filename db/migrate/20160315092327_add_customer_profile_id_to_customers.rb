class AddCustomerProfileIdToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :customer_profile_id, :string
  end
end
