module Skyscanner
  class Flights
  	attr_accessor :current_user

    def self.current_user=(current_user)
      @current_user = current_user
    end

    def self.response_result(*args)
      args.each do |arg|
        {
          welcome_state: arg[:welcome_state],
          responses: arg[:response],
          agents: arg[:agents],
          carriers: arg[:carriers],
          customer_session_id: arg[:customer_session_id],
          num_of_flight: arg[:num_of_flight] || 0,
          num_of_page: arg[:num_of_page] || 0,
          error_response: {
            is_error: arg[:is_error],
            message:  arg[:error_response]
          }
        }
      end
    end

    def self.list_flight(country=nil, currency=nil, locale=nil, originplace=nil, destinationplace=nil, outbounddate=nil, inbounddate=nil, adults=nil, locationschema=nil, cabinclass=0)
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

    	session_body = eval(session.response_body)
    	case session.code
    	when 400
    		@error_response = session_body[:ValidationErrors].first[:Message]
				return response_result(error_response: @error_response)
    	else
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
				status_code = nil
				iteneraries = []
				retry_count	= 0

				loop do 
					request.run
					@flights 				= eval(request.response.body)  
					@num_of_flight 	= (@flights.size rescue 0)
					iteneraries 		= (@flights[:Itineraries] rescue [])
					reorder_parameters(@flights) if @flights.present?
					status_code 		= request.response.code 
					retry_count += 1
					sleep(1)
					return response_result(response: @flights[:Itineraries], carriers: @carriers, places: @places, agents: @agents, num_of_flight: @num_of_flight) if (status_code.eql?(200) && iteneraries.any?) || retry_count == 6
					break if (status_code.eql?(200) && iteneraries.any?) || retry_count == 6
		    end
    	end 
	  end

	  def self.reorder_parameters(flights)
	  	@flights = flights
			@carriers = {}
			@flights[:Carriers].each do |c|
			  @carriers[c[:Id]] = c
			end;0

			@places = {}
			@flights[:Places].each do |p|
			  @places[p[:Id]] = p
			end;0

			@agents = {}
			@flights[:Agents].each do |a|
			  @agents[a[:Id]] = a
			end;0

			@flights[:Legs].each do |l|
			  l[:DestinationStation] = @places[l[:DestinationStation]] || l[:DestinationStation]
			  l[:OriginStation] = @places[l[:OriginStation]] || l[:OriginStation]
			end;0

			@legs = {}
			@flights[:Legs].each do |l|
			  l[:Carriers].each_with_index do |c, idx|
			    l[:Carriers][idx] = @carriers[c]
			  end

			  l[:OperatingCarriers].each_with_index do |c, idx|
			    l[:OperatingCarriers][idx] = @carriers[c]
			  end

			  @legs[l[:Id]] = l
			end;0

			@flights[:Itineraries].each do |it|
			  it[:PricingOptions].each do |opt|
			    opt[:Agents].each_with_index do |agent, index|
			      opt[:Agents][index] = @agents[agent] || agent
			      opt[:Agents][index] = @agents[agent] || agent
			    end
			  end

			  it[:InboundLegId] = @legs[it[:InboundLegId]] || it[:InboundLegId];
			  it[:OutboundLegId] = @legs[it[:OutboundLegId]] || it[:OutboundLegId]
			end;0
	  end
  end
end