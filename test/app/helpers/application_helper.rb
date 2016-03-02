module ApplicationHelper
  def titleize_text(text)
    text.titleize
  end

  def full_name(user_profile)
    "#{titleize_text(user_profile.first_name)} #{titleize_text(user_profile.last_name)}"
  end
end
