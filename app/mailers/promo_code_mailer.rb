class PromoCodeMailer < ApplicationMailer
  def promo_code_created(promo_code)
    @promo_code = promo_code

    mail to: @promo_code.user.email, subject: 'Promo Code'
  end
end
