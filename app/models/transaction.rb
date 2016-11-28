class Transaction < ActiveRecord::Base
  after_create :update_user_total_credit
  after_create :set_activity

  belongs_to :user

  paginates_per 10

  attr_accessor :is_referrer

  def transaction_type_label
    case self.transaction_type
    when 'payment.recurring'
      'Reoccuring Payment'
    when 'used_promo_code'
      'Promo Code'
    when 'add_to_saving'
      'Manual Payment'
    else
      self.transaction_type.try(:titleize)
    end
  end

  def self.sync_specific_id(transaction_id)
    transaction_reporting_authorize = AuthorizeNetLib::TransactionReporting.new

    transaction_detail = transaction_reporting_authorize.get_transaction_details(transaction_id)

    if transaction_detail && transaction_detail.transaction.subscription
      customer = Customer.find_by(customer_id: transaction_detail.transaction.customer.id)
      user = customer.user if customer

      if user
        if ['settledSuccessfully', 'capturedPendingSettlement'].include? transaction_detail.transaction.transactionStatus
          unless Transaction.where(trans_id: transaction_id).exists?
            transaction = Transaction.new(
              user_id: user.id,
              customer_id: customer.customer_id,
              invoice_id: transaction_detail.transaction.order.invoiceNumber,
              amount: transaction_detail.transaction.settleAmount.to_f * 100,
              trans_id: transaction_id,
              transaction_type: 'payment.recurring'
            )
            
            PaymentProcessorMailer.delay.subscription_charged(user.id, transaction.amount) if transaction.save
          end
        elsif ['communicationError', 'declined', 'generalError', 'settlementError'].include? transaction_detail.transaction.transactionStatus
          subscription_id = transaction_detail.transaction.subscription.chop
          recurring_authorize = AuthorizeNetLib::RecurringBilling.new

          recurring_authorize.cancel_subscription(subscription_id)
          subscription_status = recurring_authorize.get_subscription_status(subscription_id)

          user.create_activity(
            key: 'payment.subscription_failed', 
            owner: user, 
            recipient: user,
            parameters: {
              subscription_id: subscription_id,
              subscription_status: subscription_status,
              subscription_message: nil
            }
          )

          subscription = Subscription.where(user_id: user.id, subscription_id: subscription_id).first
          
          if subscription
            subscription.destroy
            Bank_account.where(user_id: user.id).delete_all
            PaymentProcessorMailer.delay.subscription_failed(user.id, subscription_id, subscription_status)
          end
        end
      else
        logger.info "User with customer id #{transaction_detail.transaction.customer.id} not found in the database"
      end
    else
      logger.info "Transaction with ID #{transaction_id} not found in your merchant."
    end
  end

  def self.sync_specific_batch(batch_id)
    begin
      transaction_reporting_authorize = AuthorizeNetLib::TransactionReporting.new
      transaction_authorize_list = transaction_reporting_authorize.get_transaction_list(batch_id)

      if transaction_authorize_list
        # transaction_authorize_list.each { |trans_authorize| self.sync_specific_id(trans_authorize.transId) }
        transaction_authorize_list.each { |trans_authorize| SyncTransactionWorker.perform_async(trans_authorize.transId) }
      end
    rescue => e
      logger.error e.message
    end
  end

  def self.sync_per_day
    begin
      transaction_reporting_authorize = AuthorizeNetLib::TransactionReporting.new
      batch_list = transaction_reporting_authorize.get_settled_batch_list

      batch_list.each { |batch| self.sync_specific_batch(batch.batchId) } if batch_list
    rescue => e
      logger.error e.message
    end
  end

  private
    def update_user_total_credit
      self.user.total_credit += self.amount
      self.user.save
    end

    def set_activity
      unless ["refund", "void"].include? self.transaction_type
        activity_key = 
          if self.transaction_type.eql? "add_to_saving"
            'payment.manual'
          elsif self.transaction_type.eql? "used_promo_code"
            'payment.used_promo_code'
          else
            'payment.recurring'
          end
        
        total_credit = self.user.total_credit / 100.0

        if self.is_referrer
          if self.user.group || self.user.joined_groups.present?
            members = self.user.group || self.user.joined_groups.first
            total_credit_group = members.total_credit / 100.0
            members.try(:members) << self.user
            
            # send notif to all members
            members.try(:members).each { |member| _create_activity(self.user, member, activity_key, total_credit_group) }
          else
            _create_activity(self.user, self.user, activity_key, total_credit)
          end
        else
          _create_activity(self.user, self.user, activity_key, total_credit)
        end
      end
    end

    def _create_activity(owner, recipient, activity_key, total_credit)
      owner.create_activity(
        key: activity_key, 
        owner: owner,
        recipient: recipient, 
        parameters: { 
          amount: self.amount / 100.0, 
          total_credit: total_credit,
          trans_id: self.trans_id,
          is_request_refund: false 
        }
      )
    end
end
