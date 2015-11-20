module DealsHelper
  def show_tags_room_availability(room)
    tags = ""

    tags += "<tr>"
      tags += "<td>"
        tags += room["rateDescription"].split(",").first
        tags += "<ul>"
          if room["BedTypes"]["@size"].eql? "1"
            tags += "<li>#{room["BedTypes"]["description"]}</li>"
          else
            room["BedTypes"]["BedType"].each do |bed_type|
              tags += "<li>#{bed_type["description"]}</li>"
            end
          end
        tags += "</ul>"
      tags += "</td>"

      tags += "<td>"
        tags += "<ul>"
          unless room["ValueAdds"].nil?
            if room["ValueAdds"]["@size"].eql? "1"
              tags += "<li>#{room["ValueAdds"]["ValueAdd"]["description"]}</li>"
            else
              room["ValueAdds"]["ValueAdd"].each do |option|
                tags += "<li>#{option["description"]}</li>"
              end
            end
          end
        tags += "</ul>"
      tags += "</td>"

      tags += "<td>"
        tags += currency(room["RateInfos"]["RateInfo"]["ChargeableRateInfo"]["@total"])
      tags += "</td>"

      tags += "<td>"
        tags += "<a href='#{deals_book_path(id: @room_availability["hotelId"], rate_code: room["rateCode"], room_type_code: room["roomTypeCode"])}' class='btn btn-default'>Book Now</a>"
      tags += "</td>"

    tags += "</tr>"

    tags.html_safe
  end

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

  # def title_destination
  #   session[:last_destination_search][:destinationString].split(",").first
  # end

  def currency(price)
    number_to_currency(price.to_f.round, precision: 0)
  end

  def cents_to_usd(amount)
    amount_in_usd = (amount / 100.0)
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

  def show_room_images(room_images, room_type_code)
    room_images = room_images.select { |image_hash| image_hash["roomTypeCode"].eql? room_type_code }
    image_tag(room_images.first["url"], class: "img-rounded", style: "width: 140px; height: 140px;").html_safe
  end

  # def change_image_type(url, old_type, new_type)
  #   url.gsub!("_#{old_type}.", "_#{new_type}.")
  #   if remote_file_exists?(url).eql? false
  #     url = asset_url "default-no-image.png"
  #   end
  #   url
  # end
end

