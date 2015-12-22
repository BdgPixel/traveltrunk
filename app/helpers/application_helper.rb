module ApplicationHelper
  def titleize_text(texts)
    texts.titleize
  end

  def full_name(user_profile)
    "#{titleize_texts(user_profile.first_name)} #{titleize_texts(user_profile.last_name)}"
  end
end
