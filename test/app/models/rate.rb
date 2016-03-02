class Rate < ActiveRecord::Base
  belongs_to :rater, :class_name => "Transaction"
  belongs_to :rateable, :polymorphic => true

  #attr_accessible :rate, :dimension
end
