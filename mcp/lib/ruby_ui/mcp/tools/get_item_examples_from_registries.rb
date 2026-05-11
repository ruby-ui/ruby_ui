# frozen_string_literal: true

require "ruby_ui/mcp/tools/base"

module RubyUI
  module MCP
    module Tools
      class GetItemExamplesFromRegistries < Base
        def call(items:, **)
          resolved = items.map do |n|
            c = @registry.find(n)
            c ? {name: c[:name], examples: c[:examples] || []} : nil
          end.compact
          {items: resolved, gem_version: gem_version}
        end
      end
    end
  end
end
