module Expedia
  def global_api_params_hash
    {
      'apiKey' => "5fd6485clmp3oogs8gfb43p2uf",
      'cid' => 55505,
      'minorRev' => 30,
      'locale' => "en_US",
      'currencyCode' => "USD",
    }
  end

  def current_user(current_user_params)
    current_user_params
  end

  class Hotels
    include Expedia

    def initialize(current_user_params)
      # @current_user = Expedia::current_user(current_user_params)
      # puts 'asdf'
    end

    def get_hotels_list(destination, group)
      url = 'http://api.ean.com/ean-services/rs/hotel/v3/list?'
      current_user('haha')

    end
  end
end
