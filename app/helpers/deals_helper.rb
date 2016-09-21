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
      content_tag(:div, nil, class: 'lazy deals-image', data: { original: "https://images.trvl-media.com#{ hotel_image.gsub('_t.', '_y.') }" },
        style: "background:url('https://images.trvl-media.com#{ hotel_image.gsub('_t.', '_b.') }'), url('https://images.trvl-media.com#{ hotel_image.gsub('_t.', '_l.') }') no-repeat grey; background-size: 100% 100%; height: 300px;")
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

  def number_of_adults_collection
    number_of_array = []
    1.upto(8) { |i| number_of_array << [pluralize(i, 'Guest'), i] }
    number_of_array
  end

  def selected_number_of_adult
    session[:destination].nil? ? nil : session[:destination]['number_of_adult'].to_i
  end

  def back_link_to_deals_page
    if user_signed_in?
      link_to raw("<i class='icon-deals btn-back-to-deals'></i><span>Back</span>"), deals_path, class: '', data: { no_turbolink: true }, title: 'Back to deals'
    else
      link_to raw("<i class='icon-deals btn-back-to-deals'></i><span>Back</span>"), :back, class: '', data: { no_turbolink: true }, title: 'Back to deals'
    end
  end

  def button_actions_in_deals_detail(room)
    is_bank_account = 
      if user_signed_in?
        current_user.bank_account ? true : false
      end

    link = ''
    if @group
      if @group.user_id.eql? current_user.id
        if @total_credit < (room['RateInfos']['RateInfo']['ChargeableRateInfo']['@total'].to_f * 100).to_i
          link_to "Add to savings", "#", class: "btn btn-saving btn-yellow btn-full-size display append-credit", data: { toggle: "modal", target: "#modalSavingsForm", id: @room_availability["hotelId"], rate_code: room["rateCode"], room_type_code: room["RoomType"]["@roomCode"], total: room["RateInfos"]["RateInfo"]["ChargeableRateInfo"]["@total"] }
        else
          link_to "Book Now", "javascript:void(0)", class: "btn btn-saving btn-green btn-full-size room-selected", data: { id: @room_availability["hotelId"], rate_code: room["rateCode"], room_type_code: room["RoomType"]["@roomCode"], total: room["RateInfos"]["RateInfo"]["ChargeableRateInfo"]["@total"] }
        end
      else
        if @current_user_votes_count.zero?
          link_to "Let's Go", "#", class: "btn btn-saving btn-green btn-full-size room-selected", data: { toggle: "modal", target: ".modal-lg", id: @room_availability["hotelId"], rate_code: room["rateCode"], room_type_code: room["RoomType"]["@roomCode"], total: room["RateInfos"]["RateInfo"]["ChargeableRateInfo"]["@total"], group: "member" }
        else
          link_to "Cancel Vote", deals_like_path(params[:id]), class: "btn btn-saving btn-orange-soft btn-full-size"
        end
      end
    else
      if user_signed_in?
        if @total_credit < (room['RateInfos']['RateInfo']['ChargeableRateInfo']['@total'].to_f * 100).to_i
          if current_user.bank_account
            link = link_to "Add to savings", "#", class: "btn btn-saving btn-yellow btn-full-size display append-credit", data: { toggle: "modal", target: "#modalSavingsForm", id: @room_availability["hotelId"], rate_code: room["rateCode"], room_type_code: room["RoomType"]["@roomCode"], total: room["RateInfos"]["RateInfo"]["ChargeableRateInfo"]["@total"] }
          else
            link = link_to "Add to savings", edit_profile_path(is_notice: true), class: "btn btn-saving btn-yellow btn-full-size display append-credit"
          end
        else
          link = link_to "Book Now", "javascript:void(0)", class: "btn btn-saving btn-green btn-full-size room-selected", data: { id: @room_availability["hotelId"], rate_code: room["rateCode"], room_type_code: room["RoomType"]["@roomCode"], total: room["RateInfos"]["RateInfo"]["ChargeableRateInfo"]["@total"] }
        end
      else
        link += link_to "Book Now", "javascript:void(0)", class: "btn btn-saving btn-green btn-full-size room-selected", data: { id: @room_availability["hotelId"], rate_code: room["rateCode"], room_type_code: room["RoomType"]["@roomCode"], total: room["RateInfos"]["RateInfo"]["ChargeableRateInfo"]["@total"] }
        link += '<br><br>'
        link += '<center>'
        link += link_to "Start saving for a vacation", new_user_registration_path
        link += '</center>'
      end
    end

    link.html_safe
  end

  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
    @resource.build_profile
    @resource
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def resource_class
    devise_mapping.to
  end
end
