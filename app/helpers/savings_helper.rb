module SavingsHelper
  def currency_in_usd(amount)
    amount_in_usd = (amount / 100.0)
    number_to_currency(amount_in_usd)
  end
end
