module DealsHelper
  def unescape_expedia_html(string)
    raw CGI.unescapeHTML(string)
  end

  def currency(price)
    number_to_currency(price.to_f.round, precision: 0)
  end

  def list_of_deals_div(hotel_image)
    content_tag(:div, nil, class: 'lazy deals-image', data: { original: "http://images.travelnow.com#{ hotel_image.gsub('_t.', '_y.') }" },
      style: "background:url('http://images.travelnow.com#{ hotel_image.gsub('_t.', '_b.') }'), url('http://images.travelnow.com#{ hotel_image.gsub('_t.', '_l.') }') no-repeat grey; background-size: 100% 100%; height: 300px;")
  end

  def remote_file_exists?(url)
    url = URI.parse(url)
    Net::HTTP.start(url.host, url.port) do |http|
      return http.head(url.request_uri)['Content-Type'].start_with? 'image'
    end
  end
end

