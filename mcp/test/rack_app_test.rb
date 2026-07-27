# frozen_string_literal: true

require "test_helper"
require "rack/mock_request"
require "ruby_ui/mcp/rack_app"

class RackAppTest < Minitest::Test
  def setup
    registry = RubyUI::MCP::Registry.load(TestSupport::FIXTURE_PATH)
    @app = RubyUI::MCP::RackApp.new(registry: registry)
  end

  def test_allows_production_host
    response = get("rubyui.com")
    refute_invalid_host(response)
  end

  def test_allows_www_production_host
    response = get("www.rubyui.com")
    refute_invalid_host(response)
  end

  def test_allows_loopback_host
    response = get("localhost")
    refute_invalid_host(response)
  end

  def test_rejects_dns_rebinding_host
    response = get("evil.example.com")
    assert_equal 403, response.status
    assert_includes response.body, "Invalid Host header"
  end

  def test_default_allowed_hosts_are_exactly_production_hosts
    assert_equal ["rubyui.com", "www.rubyui.com"], RubyUI::MCP::RackApp::DEFAULT_ALLOWED_HOSTS
  end

  def test_allowed_hosts_extends_via_env_var
    with_env("RUBY_UI_MCP_ALLOWED_HOSTS" => "staging.rubyui.com, other.example.com") do
      assert_equal(
        ["rubyui.com", "www.rubyui.com", "staging.rubyui.com", "other.example.com"],
        RubyUI::MCP::RackApp.allowed_hosts
      )
    end
  end

  private

  def get(host)
    Rack::MockRequest.new(@app).get("/", "HTTP_HOST" => host)
  end

  def refute_invalid_host(response)
    refute_equal 403, response.status
    refute_includes response.body, "Invalid Host header"
  end

  def with_env(vars)
    previous = vars.keys.to_h { |k| [k, ENV[k]] }
    vars.each { |k, v| ENV[k] = v }
    yield
  ensure
    previous.each { |k, v| ENV[k] = v }
  end
end
