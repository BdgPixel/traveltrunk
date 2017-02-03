namespace :flight do
  desc "TODO"
  task destiantion: :environment do
  	query = ["a","b","c","d","e","f","g","h","u","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
    country_iso_2 = ["AF","AX","AL","DZ","AS","AD","AO","AI","AQ","AG","AR","AM","AW","AU","AT","AZ","BS","BH","BD","BB","BY","BE","BZ","BJ","BM","BT","BO","BQ","BA","BW","BV","BR","IO","BN","BG","BF","BI","KH","CM","CA","CV","KY","CF","TD","CL","CN","CX","CC","CO","KM","CG","CD","CK","CR","CI","HR","CU","CW","CY","CZ","DK","DJ","DM","DO","EC","EG","SV","GQ","ER","EE","ET","FK","FO","FJ","FI","FR","GF","PF","TF","GA","GM","GE","DE","GH","GI","GR","GL","GD","GP","GU","GT","GG","GN","GW","GY","HT","HM","VA","HN","HK","HU","IS","IN","ID","IR","IQ","IE","IM","IL","IT","JM","JP","JE","JO","KZ","KE","KI","KP","KR","KW","KG","LA","LV","LB","LS","LR","LY","LI","LT","LU","MO","MK","MG","MW","MY","MV","ML","MT","MH","MQ","MR","MU","YT","MX","FM","MD","MC","MN","ME","MS","MA","MZ","MM","NA","NR","NP","NL","NC","NZ","NI","NE","NG","NU","NF","MP","NO","OM","PK","PW","PS","PA","PG","PY","PE","PH","PN","PL","PT","PR","QA","RE","RO","RU","RW","BL","SH","KN","LC","MF","PM","VC","WS","SM","ST","SA","SN","RS","SC","SL","SG","SX","SK","SI","SB","SO","ZA","GS","SS","ES","LK","SD","SR","SJ","SZ","SE","CH","SY","TW","TJ","TZ","TH","TL","TG","TK","TO","TT","TN","TR","TM","TC","TV","UG","UA","AE","GB","US","UM","UY","UZ","VU","VE","VN","VG","VI","WF","EH","YE","ZM","ZW"]

    country_iso_2.each do |iso|
  		query.each do |word|
      	request = Typhoeus.get("http://partners.api.skyscanner.net/apiservices/autosuggest/v1.0/#{iso}/USD/en-GB/?query=#{word}&apiKey=prtl6749387986743898559646983194", headers: {'Content-Type' => 'application/x-www-form-urlencoded', 'Accept' => 'application/json'})
      	request = eval(request.response_body)
        if (request[:Places] rescue false)
          request[:Places].each do |place|
        		unless Place.find_by(place_id: place[:PlaceId]).present?
        			res = Place.create(place_id: place[:PlaceId], place_name: place[:PlaceName], country_id: place[:CountryId], region_id: place[:RegionId], city_id: place[:CityId], country_name: place[:CountryName])
        			puts res.place_id
        		end
        	end
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
