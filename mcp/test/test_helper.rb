$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "minitest/autorun"
require "ruby_ui/mcp/registry"

module TestSupport
  FIXTURE_PATH = File.expand_path("fixtures/registry.json", __dir__)
end
