module SavingsHelper
  def currency_in_usd(amount)
    amount_in_usd = (amount / 100.0)
    number_to_currency(amount_in_usd)
  end

  def change_last_character(name)
    char = name[-1,1].downcase
    if char.eql?("s")
      name = "#{name}' savings".titleize
    else
      name = "#{name}'s savings".titleize
    end
  end
end
