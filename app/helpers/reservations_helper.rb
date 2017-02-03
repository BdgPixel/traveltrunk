module ReservationsHelper
  COLLECTION_REASONS = [
    ['Hotel asked me to cancel', 'HOC'],
    ['Change of plans', 'COP'],
    ['Found a better price', 'FBP'],
    ['Found a better hotel', 'FBH'],
    ['Decided to cancel my plans', 'CNL'],
    ['Rather not say', 'NSY'],
    ['Other', 'OTH']
  ]

  def expedia_customer_full_name(customer)
    "#{customer['firstName']} #{customer['lastName']}".titleize
  end

  def expedia_reserved_for(guest)
    "#{guest['firstName']} #{guest['lastName']}".titleize
  end

  def expedia_hotel_address_format(hotel)
    "#{hotel['city']}, #{hotel['stateProvinceCode']}
      #{hotel['postalCode']} #{hotel['countryCode']}"
  end

  def expedia_customer_address_format(customer)
    "#{customer['address1']}, #{customer['city']}, #{customer['stateProvinceCode']} #{customer['postalCode']} #{customer['countryCode']}"
  end

  def expedia_nightly_rates_per_room(rates, key_date)
    tags = ""

    if rates["@size"].to_i > 1
      rates["NightlyRate"].each_with_index do |rate, key_rate|
        tags += "<td class='text-right'>#{number_to_currency rate["@rate"]}</td>" if key_date.eql? key_rate
      end
    else
      tags += "<td class='text-right'>#{number_to_currency(rates["NightlyRate"]["@rate"].to_f)}</td>"
    end

    tags.html_safe
  end

  def expedia_surcharge(reservation)
    cost = reservation['RateInfos']['RateInfo']['ChargeableRateInfo']['Surcharges']
    label_country = europe_countries(reservation['hotelCountryCode'])
    tags = ""

    if cost['@size'].to_i > 1
      cost['Surcharge'].each do |surcharge|
        tags += "<tr><td>"
          tags += "<font style='font-family:Tahoma,sans-serif;font-size:13px'>"

          if surcharge['@type'].eql? 'SalesTax'
            tags += "<b>Sales Tax </b>"
            tags += "<p style='margin-top:0'>"
            tags += "<font style='font-family:Tahoma,sans-serif;font-size:11px'>(already included in total price)</font>"
            tags += "</p'>"
          else
            tags += "<b>#{label_country.capitalize}</b>"
          end

          tags +="</font>"
        tags +="</td>"
        tags += "<td class='text-right'>"
          tags += "<font style='font-family:Tahoma,sans-serif;font-size:13px'>#{number_to_currency(surcharge['@amount'].to_f)}</font>"
        tags +="</td></tr>"
      end
    else
      tags += "<tr><td>"
        tags += "<font style='font-family:Tahoma,sans-serif;font-size:13px'>"

          if cost['@type'].eql? 'SalesTax'
            tags += "<b>Sales Tax </b>"
            tags += "<p style='margin-top:0'>"
              tags += "<font style='font-family:Tahoma,sans-serif;font-size:11px'>(already included in total price)</font>"
            tags += "</p'>"
          else
            tags += "<b>#{label_country.capitalize}</b>"
          end

        tags +="</font>"
      tags +="</td>"
      tags += "<td class='text-right'>"
        tags += "<font style='font-family:Tahoma,sans-serif;font-size:13px'>#{number_to_currency(cost['Surcharge']['@amount'].to_f)}</font>"
      tags +="</td></tr>"
    end

    tags.html_safe
  end

  def status_reservation(status_code)
    label =
      case status_code
      when 'CF' then 'Confirmed'
      when 'PS' then 'Pending'
      when 'ER' then 'Permanently failed'
      when 'CX' then 'Cancelled'
      end

    "#{label} (#{status_code})"
  end
end
