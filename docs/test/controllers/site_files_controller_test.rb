require "test_helper"

class SiteFilesControllerTest < ActionDispatch::IntegrationTest
  test "llms txt is available through routing" do
    assert_routing "/llms.txt", controller: "site_files", action: "llms"

    get "/llms.txt"

    assert_response :success
    assert_equal "text/plain", response.media_type
    assert_includes response.body, "# RubyUI"
    assert_includes response.body, "## Core docs"
    assert_includes response.body, "https://rubyui.com/docs/introduction"
    assert_includes response.body, "https://rubyui.com/llms-full.txt"
  end

  test "llms full txt is available through routing" do
    assert_routing "/llms-full.txt", controller: "site_files", action: "llms_full"

    get "/llms-full.txt"

    assert_response :success
    assert_equal "text/plain", response.media_type
    assert_includes response.body, "# RubyUI Full LLM Reference"
    assert_includes response.body, "## Component catalog"
    assert_includes response.body, "bin/rails g ruby_ui:component Button"
  end

  test "sitemap xml is available through routing" do
    assert_routing "/sitemap.xml", controller: "site_files", action: "sitemap"

    get "/sitemap.xml"

    assert_response :success
    assert_equal "application/xml", response.media_type
    assert_includes response.body, "<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">"
    assert_includes response.body, "<loc>https://rubyui.com/</loc>"
    assert_includes response.body, "<loc>https://rubyui.com/docs/button</loc>"
  end
end
