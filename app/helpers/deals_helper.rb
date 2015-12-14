module DealsHelper
  include ActionView::Helpers::UrlHelper

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

  def welcome_user_first_sign_in
    link = link_to "<u>Create a profile</u>".html_safe, edit_profile_path

    "Welcome “#{current_user.profile.first_name.titleize}”, Thank you for signing up to Travel Trunk. To begin please #{link} and start saving for your next getaway. As you continue to save we will display hotels you can afford based on your destination getaway and savings. It’s that simple!"

  end
end

