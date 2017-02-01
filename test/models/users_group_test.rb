# == Schema Information
#
# Table name: users_groups
#
#  id               :integer          not null, primary key
#  invitation_token :string
#  accepted_at      :datetime
#  user_id          :integer
#  group_id         :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

require 'test_helper'

class UsersGroupTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
