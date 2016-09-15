class Admin::RefundsController < Admin::ApplicationController
  include ExceptionErrorResponse
  
  before_action :set_refund, only: :update
  before_action :set_customers_authorize_net, only: :update
  before_action :authenticate_user!

  def index
    @refunds = Refund.order(created_at: :desc).page params[:page]
  end

  def update
    if @response_refund_transaction.nil?
      redirect_to admin_refunds_url, notice: @error_response
    else
      total_credit = @refund.user.total_credit - @refund.amount
      refund_trans_id = @response_refund_transaction.transactionResponse.transId

      if @refund.update_attributes(confirmed: 'yes', refund_trans_id: refund_trans_id)
        @refund.user.update_attributes(total_credit: total_credit)

        transaction = Transactions.new(
          amount: @refund.amount,
          invoice_id: AuthorizeNetLib::Global.generate_random_id('inv'),
          customer_id: @refund.user.customer.customer_id,
          transaction_type: @transaction_type, 
          ref_id: @response_refund_transaction.refId,
          trans_id: refund_trans_id,
          user_id: @refund.user_id
        )

        if transaction.save
          current_user.create_activity(
            key: "payment.#{@transaction_type}", 
            owner: current_user,
            recipient: @refund.user, 
            parameters: { 
              amount: @refund.amount, 
              total_credit: @refund.user.total_credit,
              trans_id: @refund.trans_id,
              refund_trans_id: refund_trans_id
            }
          )
        end

        PaymentProcessorMailer.delay.refund_approved(@refund, @transaction_type)
      end

      notice = "Successfully refunded a transaction (Transaction ID #{@response_refund_transaction.transactionResponse.transId}"
      redirect_to admin_refunds_url, notice: notice
    end
  end

  private
    def set_refund
      @refund = Refund.find(params[:id])
    end

    def set_customers_authorize_net
      payment_authorize  = AuthorizeNetLib::PaymentTransactions.new
      transaction_authorize  = AuthorizeNetLib::TransactionReporting.new

      begin
        transaction_detail = transaction_authorize.get_transaction_details(@refund.trans_id)
        last_card_number = transaction_detail.transaction.payment.creditCard.cardNumber.try(:last, 4)
        exp_card =  transaction_detail.transaction.payment.creditCard.expirationDate

        transaction = Transaction.select(:amount, :ref_id, :trans_id).find_by(trans_id: @refund.trans_id)
        
        params_refund = {
          ref_id: transaction.ref_id,
          trans_id: transaction.trans_id,
          amount: transaction.amount.to_f / 100.0,
          last_card_number: last_card_number,
          exp_card: exp_card
        }
        
        transaction_status = transaction_detail.transaction.transactionStatus

        @response_refund_transaction = 
          if transaction_status.eql? 'settledSuccessfully'
            @transaction_type = 'refund'
            payment_authorize.refund_transaction(params_refund)
          elsif transaction_status.eql?('capturedPendingSettlement') || transaction_status.eql?('authorizedPendingCapture')
            @transaction_type = 'void'
            payment_authorize.void_transaction(params_refund.except(:amount, :last_card_number, :exp_card))
          end
        
      rescue Exception => e
        logger.error e.message
        
        if e.is_a?(AuthorizeNetLib::RescueErrorsResponse)
          @error_response = 
            if e.error_message[:response_error_text]
              "#{e.error_message[:response_message]} #{e.error_message[:response_error_text]}"
            else
              e.error_message[:response_message].split('-').last.strip
            end
            
          self.errors.add(:authorize_net_error, @error_response)
          false
        else
          logger.error e.message
          e.backtrace.each { |line| logger.error line }
        end
      end
    end
end
