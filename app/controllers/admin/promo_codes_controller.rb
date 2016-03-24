class Admin::PromoCodesController < Admin::ApplicationController
  before_action :set_promo_code, only: :create
  before_action :authenticate_user!

  def index
    @promo_codes = PromoCode.all
    # @users = User.includes(:profile).select(:id, :email).where(admin: false)
  end

  def new
    @user_collections = User.list_of_user_collections
    @token = SecureRandom.uuid

    @promo_code = PromoCode.new(token: @token)
  end

  def create
    begin
      @promo_code = PromoCode.new(set_promo_code)

      exp_month = set_promo_code[:exp_month].rjust(2, '0')
      exp_year = set_promo_code[:exp_year][-2, 2]
      invoice_cc = AuthorizeNetLib::Global.genrate_random_id('inv_cc')

      params_hash = {
        amount: set_promo_code[:amount].to_f,
        card_number: set_promo_code[:card_number],
        exp_date: "#{exp_month}#{exp_year}",
        cvv: set_promo_code[:cvc],
        order: { 
          invoice: invoice_cc[0..19],
          description: 'Promo Code'
        }
      }
      
      payment = AuthorizeNetLib::PaymentTransactions.new
      response_payment = payment.charge(params_hash)

      if response_payment.messages.resultCode.eql? 'Ok'
        amount_in_cents = (@promo_code.amount.to_f * 100).to_i

        transaction = @promo_code.user.transactions.new(
          amount: amount_in_cents, 
          transaction_type: 'deposit',
          invoice_id: invoice_cc,
          ref_id: response_payment.refId,
          trans_id: response_payment.transactionResponse.transId
        )

        transaction.save

        if @promo_code.save
          PromoCodeMailer.promo_code_created(@promo_code).deliver_now
          redirect_to admin_promo_codes_url, notice: 'Promo code was successfully created'
        else
          @user_collections = User.list_of_user_collections
          render :new
        end
      else
        flash[:error] = 'Some errors occured'
        format.js
        format.html { redirect_to new_admin_promo_code_url, notice: flash[:error] }
      end
    rescue Exception => e
      # @error_response = "#{e.message} #{e.error_message[:response_error_text]}"
      redirect_to new_admin_promo_code_url, alert: e.message
    end
  end

=begin
  # create using stripe
  def create
    @promo_code = PromoCode.new(set_promo_code)
    begin
      amount_to_cents    = @promo_code.amount.to_f * 100
      charge = Stripe::Charge.create(
        amount: amount_to_cents.to_i, # amount in cents, again
        currency: "usd",
        source: params[:stripeToken],
        description: "Promo code payment"
      )

      if charge.paid
        transaction = @promo_code.user.transactions.new(amount: charge.amount, transaction_type: 'deposit')
        transaction.save

        if @promo_code.save
          PromoCodeMailer.promo_code_created(@promo_code).deliver_now
          redirect_to admin_promo_codes_url, notice: 'Promo code was successfully created'
        else
          @user_collections = User.list_of_user_collections
          render :new
        end

      else
        flash[:error] = 'Some errors occured'
        format.js
        format.html { redirect_to promo_codes_activation_url, notice: flash[:error] }
      end
    rescue Stripe::CardError => e
      redirect_to promo_codes_activation_url, alert: e.message
    end
  end
=end

  def destroy
    promo_code = PromoCode.find params[:id]
    if promo_code.destroy
      redirect_to admin_promo_codes_url, notice: 'Promo code has been deleted'
    else
      redirect_to admin_promo_codes_url, notice: 'Some errors occurred when deleting promo code'
    end
  end

  private
    def set_promo_code
      params.require(:promo_code).permit(:token, :amount, :exp_date, :is_status, :user_id, :exp_month, :exp_year, :card_number, :stripe_token, :cvc)
    end
end
