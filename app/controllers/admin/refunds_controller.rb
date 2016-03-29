class Admin::RefundsController < ApplicationController
  before_action :set_refund, only: :update
  before_action :set_customers_authorize_net, only: :update

  def index
    @refunds = Refund.all
  end

  def update
    if @response_refund_transaction.nil?
      redirect_to admin_refunds_url, notice: @error_response
    else
      total_credit = @refund.user.total_credit - @refund.amount
      
      if @refund.update_attributes(confirmed: 'yes')
        @refund.user.update_attributes(total_credit: total_credit)

        current_user.create_activity(
          key: "refund.approved", 
          owner: current_user,
          recipient: @refund.user, 
          parameters: { 
            amount: @refund.amount, 
            total_credit: @refund.user.total_credit
          }
        )

        PaymentProcessorMailer.approved(@refund).deliver_now
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
        last_card_number = transaction_detail.transaction.payment.creditCard.cardNumber[-4..-1]
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
            payment_authorize.refund_transaction(params_refund)
          elsif transaction_status.eql?('capturedPendingSettlement') || transaction_status.eql?('authorizedPendingCapture')
            payment_authorize.void_transaction(params_refund.except(:amount, :last_card_number, :exp_card))
          else
            puts transaction_status
          end
        
      rescue Exception => e
        @error_response = "#{e.message}  #{e.error_message[:response_error_text]}"
      end
    end
end
