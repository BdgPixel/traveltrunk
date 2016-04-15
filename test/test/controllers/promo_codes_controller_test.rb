require 'test_helper'

class PromoCodesControllerTest < ActionController::TestCase
  test "should get activation" do
    get :activation
    assert_response :success
  end

  test "should get update" do
    get :update
    assert_response :success
  end

end
