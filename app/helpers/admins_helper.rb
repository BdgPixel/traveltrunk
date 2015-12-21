module AdminsHelper
  def genrate_token
    token = SecureRandom.uuid
    if !token.eql?(SecureRandom.uuid)
      token
    else
      token = SecureRandom.uuid
    end
  end

  def show_tokens(promo_code)
    if promo_code
      promo_code.token
    else
      "-"
    end
  end

  def show_status(promo_code)
    today = Date.today

    if today <= promo_code.exp_date
      if promo_code.is_status
        "Used"
      else
        "Not Used"
      end
    else
      "Expired date"
    end
  end

  def show_button_promo(user)
    today = Date.today
    tags = ""
    if user.promo_code
      if today <= user.promo_code.exp_date
        if user.promo_code.token && user.promo_code.is_status
          tags = "<button class='btn btn-orange btn-xs' data-target='#modalPromoCode' data-toggle='modal' data-id='#{user.id}' data-token='#{genrate_token}' type='button'>
            <span class='glyphicon glyphicon-plus'></span>&nbsp;Add Promo Code</button>"
        else
          tags = "<button class='btn btn-orange btn-xs' data-target='#modalPromoCode' data-toggle='modal' data-id='#{user.id}' data-token='#{genrate_token}' type='button' disabled>
            <span class='glyphicon glyphicon-plus'></span>&nbsp;Add Promo Code</button>"
        end
      else
        tags = "<button class='btn btn-orange btn-xs' data-target='#modalPromoCode' data-toggle='modal' data-id='#{user.id}' data-token='#{genrate_token}' type='button'>
            <span class='glyphicon glyphicon-plus'></span>&nbsp;Add Promo Code</button>"
      end
    else
      tags = "<button class='btn btn-orange btn-xs' data-target='#modalPromoCode' data-toggle='modal' data-id='#{user.id}' data-token='#{genrate_token}' type='button'>
            <span class='glyphicon glyphicon-plus'></span>&nbsp;Add Promo Code</button>"
    end
    tags.html_safe
  end
end
