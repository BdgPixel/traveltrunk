module DealsHelper
  include ActionView::Helpers::UrlHelper

  def unescape_expedia_html(string)
    raw CGI.unescapeHTML(string)
  end

  def currency(price)
    number_to_currency(price.to_f.round, precision: 0)
  end

  def list_of_deals_div(hotel_image)
    if hotel_image
      content_tag(:div, nil, class: 'lazy deals-image', data: { original: "https://images.travelnow.com#{ hotel_image.gsub('_t.', '_y.') }" },
        style: "background:url('https://images.travelnow.com#{ hotel_image.gsub('_t.', '_b.') }'), url('https://images.travelnow.com#{ hotel_image.gsub('_t.', '_l.') }') no-repeat grey; background-size: 100% 100%; height: 300px;")
    end
  end

  def welcome_user_first_sign_in
    link = link_to "<u>Create a profile</u>".html_safe, edit_profile_path
    "Welcome <b>“#{titleize_text(current_user.profile.first_name)}”</b>, Thank you for signing up to Travel Trunk. To begin please #{link} and start saving for your next getaway. As you continue to save we will display hotels you can afford based on your destination getaway and savings. It’s that simple!.".html_safe
  end

  def tax_values(taxs)
    tags = ""
    if taxs["Surcharges"].present? && taxs["Surcharges"]["@size"].to_i > 1
      taxs["Surcharges"]["Surcharge"].select do |tax|
        if tax["@type"].eql? "TaxAndServiceFee"
          tags += "<tr><td><b>#{tax['@type']}</b></td>"
          tags += "<td>#{number_to_currency tax["@amount"]}</td></tr>"
        end
      end

      tags.html_safe
    end
  end

  # def tax_values(taxs)
  #   tags = ""
  #   if taxs["Surcharges"].present? && taxs["Surcharges"]["@size"].to_i > 1
  #     taxs["Surcharges"]["Surcharge"].select do |tax|
  #       unless tax["@type"].eql? "TaxAndServiceFee"
  #         tags += "<tr><td><b>#{tax['@type']}</b></td>"
  #         tags += "<td>#{number_to_currency tax["@amount"]}</td></tr>"
  #       end
  #     end

  #     tags.html_safe
  #   end
  # end

  def nightly_rates_per_room(rates, key_date)
    tags = ""
    
    if rates["@size"].to_i > 1
       rates["NightlyRate"].each_with_index do |rate, key_rate|
        tags += "<td>#{number_to_currency rate["@rate"]}</td>" if key_date.eql? key_rate
      end
    else
      tags += "<td>#{number_to_currency(rates["NightlyRate"]["@rate"].to_f)}</td>"
    end

    tags.html_safe
  end
end

