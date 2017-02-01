# == Schema Information
#
# Table name: refunds
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  trans_id        :string
#  refund_trans_id :string
#  confirmed       :string           default("pending")
#  amount          :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Refund < ActiveRecord::Base
  include PublicActivity::Model
  
  belongs_to :user

  paginates_per 10
end
