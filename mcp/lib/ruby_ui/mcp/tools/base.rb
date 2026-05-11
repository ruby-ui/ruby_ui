# frozen_string_literal: true

require "json"

module RubyUI
  module MCP
    module Tools
      class Base
        def initialize(registry:)
          @registry = registry
        end

        def call(**args)
          raise NotImplementedError
        end

        def gem_version
          @registry&.version
        end

        def respond
          payload = yield
          ::MCP::Tool::Response.new([{type: "text", text: ::JSON.pretty_generate(payload)}])
        rescue => e
          ::MCP::Tool::Response.new([{type: "text", text: "error: #{e.class}: #{e.message}"}], error: true)
        end
      end
    end
  end
end
