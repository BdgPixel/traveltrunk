# == Schema Information
#
# Table name: profiles
#
#  id             :integer          not null, primary key
#  first_name     :string
#  last_name      :string
#  birth_date     :date
#  gender         :string
#  address        :string
#  address_1      :string
#  address_2      :string
#  city           :string
#  state          :string
#  postal_code    :string
#  country_code   :string
#  image          :string
#  user_id        :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  home_airport   :text
#  place_to_visit :text
#

require 'test_helper'

class ProfileTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
