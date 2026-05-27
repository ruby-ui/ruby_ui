# frozen_string_literal: true
require "rails/engine"

module RubyUI
  module MCP
    class Engine < ::Rails::Engine
      isolate_namespace RubyUI::MCP

      initializer "ruby_ui.mcp.eager_load_rack_app", after: :load_config_initializers do
        require "ruby_ui/mcp/rack_app"
      end
    end
  end
end
