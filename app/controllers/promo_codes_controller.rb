class PromoCodesController < ApplicationController
  before_action :authenticate_user!

  def activation; end

  def update
    today = Date.today

    if params[:promo_code][:token].empty?
      flash[:error] = "Can't be blank"

      respond_to do |format|
        format.js
        format.html { redirect_to promo_codes_activation_url }
      end
    else
      @promo_code = PromoCode.find_by(user_id: current_user.id, token: params[:promo_code][:token])

      respond_to do |format|
        if @promo_code
          if @promo_code.is_expired?
            flash[:error] = "Your promo code is expired"

            format.js
            format.html { redirect_to promo_codes_activation_url, notice: flash[:error] }
          else
            if @promo_code.status.eql?('available')
              @promo_code.update_attributes(status: 'used')
             
              amount_in_cents = (@promo_code.amount.to_f * 100).to_i

              invoice_cc = AuthorizeNetLib::Global.generate_random_id('inv_upc')

              Transaction.create(
                transaction_type: 'used_promo_code',
                amount: amount_in_cents, 
                customer_id: @promo_code.user.customer.customer_id,
                invoice_id: invoice_cc,
                user_id: @promo_code.user.id
              )

              flash[:notice] = 'Your promo code has been activated'

              format.js { render js: "window.location.href='#{savings_url}'", notice: flash[:notice]   }
              format.html { redirect_to promo_codes_activation_url, notice: flash[:notice] }
            else
              flash[:error] = 'Promo code already used'

              format.js
              format.html { redirect_to promo_codes_activation_url }
            end
          end
        else
          flash[:error] = 'Invalid promo code'
          format.js {}
          format.html { redirect_to promo_codes_activation_url }
        end
      end

    end
  end
end
