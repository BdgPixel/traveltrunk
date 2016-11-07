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
      link_to(root_path, class: 'navbar-brand') do
        tags += image_tag("logo1.png")
        tags += content_tag(:span, 'TravelTrunk')
        
        tags.html_safe
      end
    end
  end

  def message_type(message, notification)
    if message.sent_messageable_id.eql? current_user.id
      'read'
    else
      notification.is_read ? 'read' : 'unread'
    end
    # if is_group
    #   unless message.sent_messageable_id.eql? current_user.id
    #     message.opened ? 'read' : 'unread'
    #   end
    # else
    #   if message.received_messageable_id.eql? current_user.id
    #     message.opened ? 'read' : 'unread'
    #   end
    # end
  end

  def link_message(message)
    if message.topic
      savings_path(anchor: 'collapseGroupChat', open_group_chat: true)
    else
      message_path(message.id, anchor: 'newMessage')
    end
  end
end
