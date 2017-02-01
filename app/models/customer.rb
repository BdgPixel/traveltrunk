# == Schema Information
#
# Table name: customers
#
#  id                  :integer          not null, primary key
#  customer_id         :string
#  user_id             :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  customer_profile_id :string
#

class Customer < ActiveRecord::Base
  belongs_to :user
end
