# frozen_string_literal: true

require "ruby_ui/mcp/tools/base"

module RubyUI
  module MCP
    module Tools
      class ViewItemsInRegistries < Base
        def call(items:, **)
          resolved = []
          unresolved = []
          items.each do |name|
            comp = @registry.find(name)
            comp ? resolved << comp : unresolved << name
          end
          {items: resolved, unresolved: unresolved, gem_version: gem_version}
        end
      end
    end
  end
end
