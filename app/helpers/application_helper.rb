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
  end

  def message_notification_class(message_action_type, notification_is_read)
    if message_action_type.eql? 'send'
      'read'
    else
      notification_is_read ? 'read' : 'unread'
    end
  end

  def link_message(message)
    if message.topic
      savings_path(anchor: 'collapseGroupChat', open_group_chat: true)
    else
      message_path(message.id, anchor: 'newMessage')
    end
  end

  def generate_deal_thumbnail(deal_string, is_notification = false)
    deal_string_info = deal_string.scan(/\[shared: (.*?)\]/)

    if deal_string_info.present?
      image, title, url = deal_string_info.last.first.split('|')

      if is_notification
        deal_string.gsub!(/\[shared: (.*?)\]/, "Shared #{title} ") # don't remove the space after interpolation
        deal_string = truncate(deal_string, length: 60, omission: '...')
      else
        deal_thumbnail_html =
          content_tag :div, class: 'wrapper-message-conversation no-padding' do
            concat(content_tag(:div, class: 'title-hotel') {
              content_tag(:span, truncate(title, length: 17, omission: '...'))
            })

            concat(link_to(url, class: 'thumbnail') {
              image_tag image, class: 'show-hotel-image' 
            })
          end

        deal_string.gsub!(/\[shared: (.*?)\]/, deal_thumbnail_html)
      end
    end

    deal_string.html_safe
  end
end
