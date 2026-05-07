require "test_helper"

class ThemesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get theme_path("violet")
    assert_response :success
  end
end
