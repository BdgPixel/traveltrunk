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
    @promo_code = PromoCode.new(set_promo_code)

    if @promo_code.save
      PromoCodeMailer.promo_code_created(@promo_code).deliver_now
      redirect_to admin_promo_codes_url, notice: 'Promo code was successfully created'
    else
      @user_collections = User.list_of_user_collections
      render :new
    end
  end

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
      params.require(:promo_code).permit(:token, :amount, :exp_date, :is_status, :user_id)
    end
end
