# == Schema Information
#
# Table name: places
#
#  id           :integer          not null, primary key
#  place_id     :string
#  place_name   :string
#  country_id   :string
#  region_id    :string
#  city_id      :string
#  country_name :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Place < ActiveRecord::Base
end
