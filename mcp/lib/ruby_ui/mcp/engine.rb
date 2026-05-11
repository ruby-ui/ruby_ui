# frozen_string_literal: true
require "rails/engine"

module RubyUI
  module MCP
    class Engine < ::Rails::Engine
      isolate_namespace RubyUI::MCP

      initializer "ruby_ui.mcp.load_registry" do
        require "ruby_ui/mcp/registry" # TODO: Task 2 — Registry implementation
        RubyUI::MCP.registry # eager load, fail fast on bad registry
      end
    end
  end
end
