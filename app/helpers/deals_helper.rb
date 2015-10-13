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
    session[:last_destination_search]["destinationString"].split(",").first
  end

  def list_of_deals_div(list)
    image_string_url = "http://images.travelnow.com#{ change_image_type(list["thumbNailUrl"], 't', 'y') }"
    if remote_file_exists?(image_string_url).eql? false
      content_tag(:div, nil, class: "hello", style: "background: url('../assets/default-no-image.png'); background-size: 100% 100%; height: 300px;")
    else
      content_tag(:div, nil, class: "hello", style: "background: url('#{ image_string_url }'); background-size: 100% 100%; height: 300px;")
    end
  end

  def remote_file_exists?(url)
    url = URI.parse(url)
    Net::HTTP.start(url.host, url.port) do |http|
      return http.head(url.request_uri)['Content-Type'].start_with? 'image'
    end
  end

  def change_image_type(url, old_type, new_type)
    url.gsub("_#{old_type}.", "_#{new_type}.")
  end
end

