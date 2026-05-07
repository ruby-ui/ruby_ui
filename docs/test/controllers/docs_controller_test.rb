require "test_helper"

class DocsControllerTest < ActionDispatch::IntegrationTest
  test "should get typography" do
    get docs_typography_url
    assert_response :success
  end
end
