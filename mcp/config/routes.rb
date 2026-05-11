RubyUI::MCP::Engine.routes.draw do
  match "/", to: RubyUI::MCP::RackApp, via: %i[get post delete], as: :mcp
end
