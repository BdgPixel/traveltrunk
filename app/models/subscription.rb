class Subscription < ActiveRecord::Base
  belongs_to :user

  def params_hash(params_hash )
    {
      subscription_id: params_hash[:subscription_id],
      amount: params_hash[:plan][:amount].to_f * 100,
      interval: params_hash[:plan][:interval_unit],
      interval_count: params_hash[:plan][:interval_length],
      plan_name: params_hash[:plan][:plan_name],
      user_id: params_hash[:user_id]
    }
  end
end
