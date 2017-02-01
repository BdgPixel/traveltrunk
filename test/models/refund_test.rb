# == Schema Information
#
# Table name: refunds
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  trans_id        :string
#  refund_trans_id :string
#  confirmed       :string           default("pending")
#  amount          :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'test_helper'

class RefundTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
