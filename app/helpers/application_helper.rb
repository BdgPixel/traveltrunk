module ApplicationHelper
  def format_string_expedia_to_date(date)
    date = date.split("/")
    "#{date[1]}/#{date[0]}/#{date[2]}".to_date.strftime("%B %d, %Y")
  end

  # def convert_string_to_date(start_date, end_date, average_rate, action_name = nil)
  #   start_date = start_date.split("/")
  #   end_date = end_date.split("/")
  #   format_start_date = Date.new(start_date[2].to_i, start_date[0].to_i, start_date[1].to_i)
  #   format_end_date = Date.new(end_date[2].to_i, end_date[0].to_i, end_date[1].to_i)
  #   tags = ""
  #   list_dates =(format_start_date..format_end_date).to_a
  #   list_dates.pop
  #   list_dates.each do |list_date|
  #     if action_name
  #       tags += "<div class='col-md-6'>"
  #         tags += "#{list_date.to_formatted_s(:short)}"
  #       tags += "</div>"
  #       tags += "<div class='col-md-6'>"
  #         tags += "#{number_to_currency(average_rate)}"
  #       tags += "</div>"
  #     else
  #       tags += "<tr>"
  #       tags += "<td>#{list_date.to_formatted_s(:short)}</td>"
  #       tags += "<td>#{number_to_currency(average_rate)}</td>"
  #       tags += "</tr>"
  #     end
  #   end

  #   tags.html_safe
  # end
end
