module ApplicationHelper
  def titleize_text(text)
    text.titleize
  end

  def full_name(user_profile)
    "#{titleize_text(user_profile.first_name)} #{titleize_text(user_profile.last_name)}"
  end

  def display_icon_traveltrunk
    tags = ""
    if user_signed_in?
      if current_user.admin?
        link_to(admin_promo_codes_path, class: 'navbar-brand') do
          tags += image_tag("logo1.png")
          tags += content_tag(:span, 'TravelTrunk')

          tags.html_safe
        end
      else
        link_to(root_path, class: 'navbar-brand') do
          tags += image_tag("logo1.png")
          tags += content_tag(:span, 'TravelTrunk')
          
          tags.html_safe
        end
      end
    else
      unless controller_name.eql? 'sessions'
        link_to(admin_promo_codes_path, class: 'navbar-brand') do
          tags += image_tag("logo1.png")
          tags += content_tag(:span, 'TravelTrunk')
          
          tags.html_safe
        end
      end
      # tags.html_safe
    end
  end
end
