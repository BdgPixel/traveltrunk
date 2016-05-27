module SavingsHelper
  def currency_in_usd(amount, condition = false)
    amount_in_usd = (amount.to_f / 100.0)
    condition ? amount_in_usd : number_to_currency(amount_in_usd)
  end

  def add_apostrophe(name)
    char = name[-1,1].downcase
    if char.eql?("s")
      name = "#{titleize_text name}' savings".titleize
    else
      name = "#{titleize_text name}'s savings".titleize
    end
  end

  def savings_interval(interval, interval_count)
    interval_unit = ['days', 'months']

    if interval_unit.include?(interval) && interval_count.eql?(7)
      'week'
    elsif interval_unit.include?(interval) && interval_count.eql?(14)
      pluralize(2, 'week')
    else
      'month'
    end
  end

  def payment_frequency_label(frequency, frequency_unit = nil)
    if frequency_unit.eql?('day')
      case frequency
      when 'Weekly' then 'seven days'
      when 'Bi Weekly' then 'fourteen days'
      when 'Monthly' then 'thirty days'
      end
    else
      case frequency
      when 'Weekly' then 'week'
      when 'Bi Weekly' then 'two weeks'
      when 'Monthly' then 'month'
      end
    end
  end
end
