# frozen_string_literal: true

require "ruby_ui/mcp/tools/base"

module RubyUI
  module MCP
    module Tools
      class SearchItemsInRegistries < Base
        def call(query:, limit: 10, **)
          {items: @registry.search(query, limit: limit), gem_version: gem_version}
        end
      end
    end
  end
end
