module FlightHelper
  include ActionView::Helpers::UrlHelper

  def parse_date str
  	date = Date.parse(str).strftime("%m/%d/%Y at %I:%M%p")
  end

end
