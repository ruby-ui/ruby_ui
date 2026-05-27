# frozen_string_literal: true

require "rack/attack"

class Rack::Attack
  throttle("mcp/ip", limit: 60, period: 60.seconds) do |req|
    req.ip if req.path.start_with?("/mcp")
  end
end

Rails.application.config.middleware.use Rack::Attack
