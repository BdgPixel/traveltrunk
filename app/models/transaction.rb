class Transaction < ActiveRecord::Base
  after_create :update_user_total_credit
  after_create :create_activity

  belongs_to :user

  # paginates_per 6

  private
    def update_user_total_credit
      unless 'add_promo_code'.include? self.transaction_type
        self.user.total_credit += self.amount
        self.user.save
      end
    end

    def create_activity
      unless ["refund", "void", "add_promo_code"].include? self.transaction_type
        activity_key = 
          if self.transaction_type.eql? "add_to_saving"
            'payment.manual'
          elsif self.transaction_type.eql? "used_promo_code"
            'payment.used_promo_code'
          else
            'payment.recurring'
          end

        self.user.create_activity(
          key: activity_key, 
          owner: self.user,
          recipient: self.user, 
          parameters: { 
            amount: self.amount / 100.0, 
            total_credit: self.user.total_credit / 100.0,
            trans_id: self.trans_id,
            is_request_refund: false 
          }
        )
      end
    end
end
