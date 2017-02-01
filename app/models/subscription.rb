# == Schema Information
#
# Table name: subscriptions
#
#  id              :integer          not null, primary key
#  plan_id         :string
#  subscription_id :string
#  amount          :integer
#  interval        :string
#  interval_count  :integer
#  plan_name       :string
#  currency        :string
#  user_id         :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Subscription < ActiveRecord::Base
  belongs_to :user

  def get_params_hash(params_hash)
    {
      subscription_id: params_hash[:subscription_id],
      amount: params_hash[:plan][:amount].to_f * 100,
      interval: params_hash[:plan][:interval_unit],
      interval_count: params_hash[:plan][:interval_length],
      plan_name: params_hash[:plan][:plan_name]
    }
  end
end
