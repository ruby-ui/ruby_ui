# frozen_string_literal: true

require "ruby_ui/mcp/server"
require "mcp/server/transports/streamable_http_transport"

module RubyUI
  module MCP
    class RackApp
      # StreamableHTTPTransport's DNS-rebinding protection validates the `Host` header
      # against an allow list that defaults to loopback only (127.0.0.1, ::1, localhost),
      # so without this every request to the production site rejects with
      # "Forbidden: Invalid Host header". Extend via RUBY_UI_MCP_ALLOWED_HOSTS
      # (comma-separated) for any additional hostnames the site is served from.
      DEFAULT_ALLOWED_HOSTS = ["rubyui.com", "www.rubyui.com"].freeze

      def self.call(env)
        (@instance ||= new).call(env)
      end

      def self.allowed_hosts
        extra = ENV["RUBY_UI_MCP_ALLOWED_HOSTS"].to_s.split(",").map(&:strip).reject(&:empty?)
        (DEFAULT_ALLOWED_HOSTS + extra).uniq
      end

      def initialize(registry: RubyUI::MCP.registry)
        server = RubyUI::MCP::Server.build(registry: registry)
        @transport = ::MCP::Server::Transports::StreamableHTTPTransport.new(
          server,
          stateless: true,
          allowed_hosts: self.class.allowed_hosts
        )
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
