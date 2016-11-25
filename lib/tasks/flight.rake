namespace :flight do
  desc "TODO"
  task destiantion: :environment do
  	query = ["a","b","c","d","e","f","g","h","u","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
		url = 'http://partners.api.skyscanner.net/apiservices/autosuggest/v1.0/US/USD/en-GB/?query=#{word}&apiKey=prtl6749387986743898559646983194'

		query.each do |word|
    	request = Typhoeus.get("http://partners.api.skyscanner.net/apiservices/autosuggest/v1.0/US/USD/en-GB/?query=#{word}&apiKey=prtl6749387986743898559646983194", headers: {'Content-Type' => 'application/x-www-form-urlencoded', 'Accept' => 'application/json'})
    	request = eval(request.response_body)
    	request[:Places].each do |place|
    		unless Place.find_by(place_id: place[:PlaceId]).present?
    			res = Place.create(place_id: place[:PlaceId], place_name: place[:PlaceName], country_id: place[:CountryId], region_id: place[:RegionId], city_id: place[:CityId], country_name: place[:CountryName])
    			puts res.place_id
    		end
    	end
		end
  end


  desc "TODO"
  task carrier: :environment do
    base_url  = 'https://www.kayak.co.id/airlines'
    doc       = Nokogiri::HTML(open(base_url))

    wrapper   = doc.css(".leftColumn .seoAirlinesList .seoAirlinesListItem")
    wrapper.each do |el|
      # get logo
      logo  = el.css('.seoAirlinesListIcon img').attr('src').text.partition('?').first
      code  = el.css('.seoAirlinesListCode').text.strip
      airline = el.css('.seoAirlinesListNameLink').text.strip
      big_logo = logo.gsub("air", "booking/larger")
      if Carrier.find_by_code(code).nil?
        # save to store
        dw    = open(big_logo.gsub("air", "booking/larger"))
        IO.copy_stream(dw, 'app/assets/images/carriers/larger/'+ code +'.png')
        puts "Already save to store for image #{dw}"
        puts "======================"
        Carrier.create(logo: logo, code: code, airline: airline, big_logo: big_logo)
        puts "Save success for #{code}"
        puts "======================"
        dwlogo    = open(logo)
        IO.copy_stream(dwlogo, 'app/assets/images/carriers/logo/'+ code +'.png')
        puts "Already save logo to store for image #{dwlogo}"
        puts "======================"
      end
    end  
  end

end
