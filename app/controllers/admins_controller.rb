class AdminsController < ApplicationController
  before_action :set_promo_code, only: :create
  before_action :authenticate_user!

  def index
    @users = User.includes(:profile).select(:id, :email).where(admin: false)

    @token = SecureRandom.uuid
    if !@token.eql?(SecureRandom.uuid)
      @token
    else
      @token = SecureRandom.uuid
    end
  end

  def create
    user = User.find params[:promo_code][:user_id]
    exp_date = Date.strptime(params[:promo_code][:exp_date], "%m/%d/%Y")

    custom_params = set_promo_code.merge(exp_date: exp_date)
    @promo_code = user.promo_code || user.build_promo_code(custom_params)

    respond_to do |format|
      if @promo_code.save
        puts 'ok'
        format.js
        format.html { redirect_to admins_url, notice: 'Promo code was successfully created' }
      else
        puts 'not'
        format.js
        # binding.pry
      end
    end

  end

  private
    def set_promo_code
      params.require(:promo_code).permit(:token, :amount, :exp_date, :is_status, :user_id)
    end
end
