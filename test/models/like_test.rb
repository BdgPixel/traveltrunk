# == Schema Information
#
# Table name: likes
#
#  id             :integer          not null, primary key
#  hotel_id       :integer
#  user_id        :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  rate_code      :string
#  room_type_code :string
#

require 'test_helper'

class LikeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
