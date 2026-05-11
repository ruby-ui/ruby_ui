# frozen_string_literal: true

require "ruby_ui/mcp/server"
require "mcp/server/transports/streamable_http_transport"

module RubyUI
  module MCP
    class RackApp
      class << self
        def call(env)
          instance.call(env)
        end

        def instance
          @instance ||= new
        end

        def reset!
          @instance = nil
        end
      end

      def initialize(registry: RubyUI::MCP.registry)
        server = RubyUI::MCP::Server.build(registry: registry)
        @transport = ::MCP::Server::Transports::StreamableHTTPTransport.new(server, stateless: true)
      end

      def call(env)
        @transport.call(env)
      rescue => e
        log_error(e)
        [500, {"content-type" => "application/json"}, [{error: "internal"}.to_json]]
      end

      private

      def log_error(error)
        return unless defined?(Rails) && Rails.respond_to?(:logger) && Rails.logger
        Rails.logger.tagged("MCP") { Rails.logger.error("#{error.class}: #{error.message}") }
      rescue
        nil
      end
    end
  end
end
