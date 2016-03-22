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

        RefundMailer.approved(@refund).deliver_now
      end

      redirect_to admin_refunds_url, notice: @response_refund_transaction
    end
  end

  private
    def set_refund
      @refund = Refund.find(params[:id])
    end

    def set_customers_authorize_net
      customer_authorize = AuthorizeNetLib::Customers.new
      payment_authorize  = AuthorizeNetLib::PaymentTransactions.new

      begin
        @customer_authorize = customer_authorize.get_customer_profile(@refund.user.customer.customer_profile_id)
        last_card_number = @customer_authorize.profile.paymentProfiles.first.payment.creditCard.cardNumber[-4..-1]
        exp_card = @customer_authorize.profile.paymentProfiles.first.payment.creditCard.expirationDate

        transaction = Transaction.select(:amount, :ref_id, :trans_id).find_by(trans_id: @refund.trans_id)

        params_refund = {
          ref_id: transaction.ref_id,
          trans_id: transaction.trans_id,
          amount: transaction.amount.to_f / 100.0,
          last_card_number: last_card_number,
          exp_card: exp_card
        }

        @response_refund_transaction = payment_authorize.refund_transaction(params_refund)
        
      rescue Exception => e
        @error_response = "#{e.message}  #{e.error_message[:response_error_text]}"
      end
    end

    def refund_params
      
    end
end
