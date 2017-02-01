# == Schema Information
#
# Table name: subscriptions
#
#  id              :integer          not null, primary key
#  plan_id         :string
#  subscription_id :string
#  amount          :integer
#  interval        :string
#  interval_count  :integer
#  plan_name       :string
#  currency        :string
#  user_id         :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'test_helper'

class SubscriptionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
