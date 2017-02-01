# == Schema Information
#
# Table name: customers
#
#  id                  :integer          not null, primary key
#  customer_id         :string
#  user_id             :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  customer_profile_id :string
#

require 'test_helper'

class CustomerTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
