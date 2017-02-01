# == Schema Information
#
# Table name: promo_codes
#
#  id         :integer          not null, primary key
#  token      :string
#  amount     :decimal(8, 2)
#  exp_date   :date
#  status     :string           default("available")
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class PromoCodeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
