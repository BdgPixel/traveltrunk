module DealsHelper
  def guests_list
    (1..16).to_a.map do |n|
      label = pluralize(n, "Guest")
      label.gsub!(" ", "+ ") if n.eql?(16)
      [label, n]
    end
  end

  def unescape_expedia_html(string)
    raw CGI.unescapeHTML(string)
  end

  def title_destination
    session[:last_destination_search][:destinationString].split(",").first
  end

  def currency(price)
    number_to_currency(price.to_f.round, precision: 0)
  end

  def list_of_deals_div(hotel_image)
    content_tag(:div, nil, class: 'lazy deals-image', data: { original: "http://images.travelnow.com#{ hotel_image }" },
      style: "background:url('#{asset_url('default-no-image.png')}') no-repeat; background-size: 100% 100%; height: 300px;")
  end

  def remote_file_exists?(url)
    url = URI.parse(url)
    Net::HTTP.start(url.host, url.port) do |http|
      return http.head(url.request_uri)['Content-Type'].start_with? 'image'
    end
  end

  def change_image_type(url, old_type, new_type)
    url.gsub!("_#{old_type}.", "_#{new_type}.")
    if remote_file_exists?(url).eql? false
      url = asset_url "default-no-image.png"
    end
    url
  end
end

