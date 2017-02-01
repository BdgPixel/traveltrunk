# == Schema Information
#
# Table name: transactions
#
#  id               :integer          not null, primary key
#  user_id          :integer
#  transaction_type :string
#  amount           :integer
#  customer_id      :string
#  invoice_id       :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  ref_id           :string
#  trans_id         :string
#  transaction_date :datetime         default(Tue, 06 Dec 2016 22:48:32 PST -08:00)
#

require 'test_helper'

class TransactionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
