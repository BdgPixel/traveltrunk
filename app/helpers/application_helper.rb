module ApplicationHelper
  def format_string_expedia_to_date(date)
    date = date.split("/")
    "#{date[1]}/#{date[0]}/#{date[2]}".to_date.strftime("%B %d, %Y")
  end
end
