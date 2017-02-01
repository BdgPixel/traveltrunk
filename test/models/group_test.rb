# == Schema Information
#
# Table name: groups
#
#  id         :integer          not null, primary key
#  name       :string
#  slug       :string
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  message_id :integer
#

require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
