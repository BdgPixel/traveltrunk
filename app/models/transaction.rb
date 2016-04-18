class Transaction < ActiveRecord::Base
  after_create :update_user_total_credit
  after_create :create_activity

  belongs_to :user

  def self.sync_specific(transaction_id)
    transaction_reporting_authorize = AuthorizeNetLib::TransactionReporting.new

    transaction_detail = transaction_reporting_authorize.get_transaction_details(transaction_id)
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

          puts transaction.inspect
          PaymentProcessorMailer.subscription_charged(user.id, transaction.amount).deliver_now if transaction.save
        end
      elsif ['communicationError', 'declined', 'generalError', 'settlementError'].include? transaction_detail.transaction.transactionStatus
        recurring_authorize = AuthorizeNetLib::RecurringBilling.new

        subscription_status =
          begin
            recurring_authorize.get_subscription_status(transaction_detail.transaction.subscription)
          rescue => e
            if e.error_message[:response_error_code].eql? 'E00035'
              recurring_authorize.get_subscription_status(transaction_detail.transaction.subscription.chop)
            end
          end

        puts subscription_status
        puts transaction_detail.transaction.subscription
        puts transaction_detail.transaction.transactionStatus
        
        user.create_activity(
          key: 'payment.subscription_failed', 
          owner: user, 
          recipient: user,
          parameters: {
            subscription_id: trans_authorize.subscription,
            subscription_status: trans_authorize.transactionStatus,
            subscription_message: nil
          }
        )

        Subscription.where(user_id: user.id, subscription_id: trans_authorize.subscription).destroy_all
        Bank_account.where(user_id: user.id).delete_all

        PaymentProcessorMailer.subscription_failed(user.id, trans_authorize.subscription, trans_authorize.transactionStatus).deliver_now
      end
    else
      puts 'user not found'
    end
  end

  def self.sync_transaction
    begin
      transaction_reporting_authorize = AuthorizeNetLib::TransactionReporting.new
      batch_list = transaction_reporting_authorize.get_settled_batch_list
      
      if batch_list
        batch_list.each do |batch|
          transaction_authorize_list = transaction_reporting_authorize.get_transaction_list(batch.batchId)

          transaction_authorize_list.each do |trans_authorize|
            transaction_detail = transaction_reporting_authorize.get_transaction_details(trans_authorize.transId)
            customer = Customer.find_by(customer_id: transaction_detail.transaction.customer.id)
            user = customer.user if customer
            
            if ['settledSuccessfully', 'capturedPendingSettlement'].include? trans_authorize.transactionStatus
              unless Transaction.where(trans_id: trans_authorize.transId).exists?
                transaction = Transaction.new(
                  user_id: user.id,
                  invoice_id: trans_authorize.invoiceNumber,
                  amount: trans_authorize.settleAmount.to_f * 100,
                  trans_id: trans_authorize.transId,
                  transaction_type: 'payment.recurring'
                )

                PaymentProcessorMailer.subscription_charged(user.id, transaction.amount).deliver_now if transaction.save
              end
            elsif ['communicationError', 'declined', 'generalError', 'settlementError'].include? trans_authorize.transactionStatus
              recurring_authorize = AuthorizeNetLib::RecurringBilling.new
              subscription_status = recurring_authorize.get_subscription_status(trans_authorize.subscription)

              user.create_activity(
                key: 'payment.subscription_failed', 
                owner: user, 
                recipient: user,
                parameters: {
                  subscription_id: trans_authorize.subscription,
                  subscription_status: trans_authorize.transactionStatus,
                  subscription_message: nil
                }
              )

              Subscription.where(user_id: user.id, subscription_id: trans_authorize.subscription).destroy_all
              Bank_account.where(user_id: user.id).delete_all

              PaymentProcessorMailer.subscription_failed(user.id, trans_authorize.subscription, trans_authorize.transactionStatus).deliver_now
            end
          end
        end
      end
    rescue => e
      logger.error e.message
    end
  end

  private
    def update_user_total_credit
      self.user.total_credit += self.amount
      self.user.save
    end

    def create_activity
      unless ["refund", "void"].include? self.transaction_type
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
