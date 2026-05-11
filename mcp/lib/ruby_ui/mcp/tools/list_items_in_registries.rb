# frozen_string_literal: true

require "ruby_ui/mcp/tools/base"

module RubyUI
  module MCP
    module Tools
      class ListItemsInRegistries < Base
        def call(**)
          {items: @registry.list, gem_version: @registry.version}
        end
      end
    end
  end
end
