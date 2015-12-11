module SavingsHelper
  def currency_in_usd(amount)
    amount_in_usd = (amount / 100.0)
    number_to_currency(amount_in_usd)
  end

  def add_apostrophe(name)
    char = name[-1,1].downcase
    if char.eql?("s")
      name = "#{name}' savings".titleize
    else
      name = "#{name}'s savings".titleize
    end
  end

  def savings_interval(interval, interval_count)
    if ['day', 'week', 'month'].include?(interval) && interval_count.eql?(1)
      interval
    else
      pluralize(interval_count, interval)
    end
  end
end
