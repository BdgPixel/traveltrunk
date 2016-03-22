class Refund < ActiveRecord::Base
  include PublicActivity::Model
  
  belongs_to :user
end
