require 'test_helper'

class DestinationsControllerTest < ActionController::TestCase
  test "should get clear" do
    get :clear
    assert_response :success
  end

end
