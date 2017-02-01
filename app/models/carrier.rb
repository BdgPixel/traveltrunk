# == Schema Information
#
# Table name: carriers
#
#  id         :integer          not null, primary key
#  code       :string
#  airline    :string
#  big_logo   :string
#  logo       :string
#  image      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Carrier < ActiveRecord::Base
end
