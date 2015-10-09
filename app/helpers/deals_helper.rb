module DealsHelper
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

  def title_destination
    session[:last_destination_search]["destinationString"].split(",").first
  end
end

