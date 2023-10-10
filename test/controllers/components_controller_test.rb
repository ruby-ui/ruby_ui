require "test_helper"

class ComponentsControllerTest < ActionDispatch::IntegrationTest
  test "should get typography" do
    get components_typography_url
    assert_response :success
  end
end
