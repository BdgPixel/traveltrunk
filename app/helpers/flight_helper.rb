module FlightHelper
  include ActionView::Helpers::UrlHelper

  def parse_date str
  	date = Date.parse(str).strftime("%m/%d/%Y at %I:%M%p")
  end

  def duration(minutes)
		hours = minutes / 60
		minutes = (minutes) % 60
		result = "#{ hours }h #{ minutes }m"
  end

  def hours(time)
  	a = Time.strptime(time, "%Y-%m-%dT%H:%M:%S")
  	a.strftime("%H:%M%P")
  end
end
