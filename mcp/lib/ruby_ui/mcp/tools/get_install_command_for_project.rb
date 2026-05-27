# frozen_string_literal: true

require "ruby_ui/mcp/tools/base"

module RubyUI
  module MCP
    module Tools
      class GetInstallCommandForProject < Base
        def call(**)
          {
            steps: [
              {title: "Add the gem", command: "bundle add ruby_ui"},
              {title: "Run the installer", command: "bin/rails g ruby_ui:install"},
              {title: "Add a component", command: "bin/rails g ruby_ui:component Button"}
            ],
            note: "Use `get_add_command_for_items` once you know which components to install."
          }
        end
      end
    end
  end
end
