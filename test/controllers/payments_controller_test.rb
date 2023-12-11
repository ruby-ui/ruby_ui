require "test_helper"

class PaymentsControllerTest < ActionDispatch::IntegrationTest
  test "should get confirmation" do
    get payments_confirmation_url
    assert_response :success
  end
end
