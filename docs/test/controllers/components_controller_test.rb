require "test_helper"

class ComponentsControllerTest < ActionDispatch::IntegrationTest
  def self.all_docs_routes
    scope_prefix = "/docs"

    Rails.application.routes.routes.select do |route|
      route.path.spec.to_s.start_with?(scope_prefix)
    end.map do |route|
      {
        method: route.verb,
        path: route.path.spec.to_s.sub(/\(\.:format\)\z/, ""),
        controller: route.defaults[:controller],
        action: route.defaults[:action]
      }
    end
  end

  all_docs_routes.each do |route|
    test "should get #{route[:action]}" do
      get route[:path]
      assert_response :success
    end
  end
end
