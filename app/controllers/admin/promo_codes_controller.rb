class Admin::PromoCodesController < Admin::ApplicationController
  before_action :promo_code_params, only: :create
  before_action :get_all_users, only: [:new, :create]
  before_action :set_promo_code, only: :destroy
  before_action :authenticate_user!

  def index
    @promo_codes = PromoCode.all.page params[:page]
  end

  def new
    @token = SecureRandom.uuid
    @promo_code = PromoCode.new(token: @token)
  end

  def create
    @promo_code = PromoCode.new(promo_code_params)
    amount_in_cents = (@promo_code.amount.to_f * 100).to_i

    # apc = add_promo_code
    invoice_cc = AuthorizeNetLib::Global.generate_random_id('inv_apc')

    if @promo_code.save
      Transaction.create(
        user_id: @promo_code.user.id,
        amount: amount_in_cents, 
        transaction_type: 'add_promo_code',
        invoice_id: invoice_cc,
        customer_id: @promo_code.user.customer.customer_id
      )

      PromoCodeMailer.promo_code_created(@promo_code).deliver_now
      redirect_to admin_promo_codes_url, notice: 'Promo code was successfully created'
    else
      render :new
    end
  end

  def destroy
    notice = @promo_code.destroy ? 'Promo code has been deleted' : 'Some errors occurred when deleting promo code'
    redirect_to admin_promo_codes_url, notice: notice
  end

  private
    def set_promo_code
      @promo_code = PromoCode.find params[:id]  
    end

    def get_all_users
      @user_collections = User.list_of_user_collections
    end

    def promo_code_params
      params.require(:promo_code).permit(:token, :amount, :exp_date, :is_status, :user_id, :exp_month, :exp_year, :card_number, :stripe_token, :cvc)
    end
end
