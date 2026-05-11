# frozen_string_literal: true

require "ruby_ui/mcp/tools/base"

module RubyUI
  module MCP
    module Tools
      class GetProjectRegistries < Base
        def call(**)
          {
            registries: [{
              name: "ruby_ui",
              url: "https://rubyui.com/mcp",
              description: "Ruby UI components for Phlex + Rails."
            }]
          }
        end
      end
    end
  end
end
