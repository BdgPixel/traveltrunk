module Skyscanner
  class Flights
  	attr_accessor :current_user

    def self.current_user=(current_user)
      @current_user = current_user
    end

    def self.create_session(country=nil, currency=nil, locale=nil, originplace=nil, destinationplace=nil, outbounddate=nil, inbounddate=nil, adults=nil, locationschema=nil, cabinclass=0)
    	url =  'http://partners.api.skyscanner.net/apiservices/pricing/v1.0'
      api_key = ENV['SKYSCANNER_API_KEY']
    	session = Typhoeus.post(url, 
    		headers: {
    			'Content-Type' => 'application/x-www-form-urlencoded',
    			'Accept' => 'application/json'
    		},
    		body: {
    				apiKey: api_key,
    				country: country,
    				currency: currency,
    				locale: locale,
    				originplace: originplace,
    				destinationplace: destinationplace,
    				outbounddate: outbounddate,
    				inbounddate: inbounddate,
    				locationschema: locationschema,
    				cabinclass: cabinclass,
    				adults: adults,
    				children: 0,
    				infants: 0,
    				locationschema: "Sky",
    				carrierschema: "Skyscanner",
    				sorttype: "carrier",
    				journeymode: "filght"
    			}
    		)

    	if session.code.eql? 201
	    	location 	= session.headers["Location"]
	    	location	= location+"?apiKey="+api_key
	    	request 	= Typhoeus::Request.new(location, followlocation: true)
				request.on_complete do |response|
				  if response.success?
				    # hell yeah
				  elsif response.timed_out?
				    # aw hell no
				    puts("got a time out")
				  elsif response.code == 0
				    # Could not get an http response, something's wrong.
				    puts(response.return_message)
				  else
				    # Received a non-successful http response.
				    puts("HTTP request failed: " + response.code.to_s)
				  end
				end

				request.run
				# reRequest API
				request.run if request.response.code.eql? 304
				if request.response.code.eql? 200
		    	@flights 				= eval(request.response.body)  
		    	@num_of_flight 	= @flights.size
		    	response_result(response: @flights)
		     #  rescue Exception => e
		     #    if e.is_a? Errno::ECONNRESET
		     #      response_result(response: [], error_response: 'Unable to get Flights list from skyscanner. Please try again later')
		     #    else
		     #      response_result(response: [], error_response: "Some errors occurred. Please contact administrator or try again later.")
		     #    end
		    	# end
		    end
	    end  
	  end

    def self.response_result(*args)
    	return args
    end
  end
end