class Refund < ActiveRecord::Base
  include PublicActivity::Model
  
  belongs_to :user

  paginates_per 10
end
