namespace :flight do
  desc "TODO"
  task destiantion: :environment do
  	query = ["a","b","c","d","e","f","g","h","u","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
		url = 'http://partners.api.skyscanner.net/apiservices/autosuggest/v1.0/US/USD/en-GB/?query=#{word}&apiKey=prtl6749387986743898559646983194'

		query.each do |word|
    	request = Typhoeus.get("http://partners.api.skyscanner.net/apiservices/autosuggest/v1.0/US/USD/en-GB/?query=#{word}&apiKey=prtl6749387986743898559646983194", 
    		headers: {
    			'Content-Type' => 'application/x-www-form-urlencoded',
    			'Accept' => 'application/json'
    		})
    	request = eval(request.response_body)
    	request[:Places].each do |place|
    		unless Place.find_by(place_id: place[:PlaceId]).present?
    			res = Place.create(place_id: place[:PlaceId], place_name: place[:PlaceName], country_id: place[:CountryId], region_id: place[:RegionId], city_id: place[:CityId], country_name: place[:CountryName])
    			puts res.place_id
    		end
    	end
		end
  end

end
