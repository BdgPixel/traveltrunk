# == Schema Information
#
# Table name: bank_accounts
#
#  id                 :integer          not null, primary key
#  bank_name          :string
#  account_number     :string
#  routing_number     :string
#  amount_transfer    :decimal(, )
#  transfer_frequency :string
#  user_id            :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'test_helper'

class BankAccountTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
