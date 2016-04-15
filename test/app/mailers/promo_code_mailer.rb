class PromoCodeMailer < ApplicationMailer
  def promo_code_created(promo_code)
    @promo_code = promo_code

    mail to: @promo_code.user.email, subject: 'TravelTrunk - Promo Code Created'
  end
end
