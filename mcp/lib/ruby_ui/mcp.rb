# frozen_string_literal: true
require "rails"
require "ruby_ui/mcp/version"
require "ruby_ui/mcp/engine"

module RubyUI
  module MCP
    def self.registry
      @registry ||= Registry.load_default
    end

    def self.root
      Engine.root
    end
  end
end
