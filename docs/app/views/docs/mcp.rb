# frozen_string_literal: true

class Views::Docs::Mcp < Views::Base
  def view_template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(
        title: "MCP Server",
        description: "Connect AI agents to Ruby UI components, source, examples, and install commands."
      )

      # About MCP
      div(class: "space-y-4") do
        Heading(level: 2) { "About MCP" }
        p(class: "text-foreground/80 leading-relaxed") do
          plain "MCP (Model Context Protocol) is an open standard for connecting AI assistants to external data sources and tools. "
          plain "Ruby UI exposes an MCP server so your AI agent can list available components, view their source files, search the docs, and generate the exact install command for your app."
        end
      end

      # Setup
      div(class: "space-y-6") do
        Heading(level: 2) { "Setup" }
        p(class: "text-foreground/80") { "Add the Ruby UI MCP server to your editor or AI client using the snippets below." }

        # Claude Code
        div(class: "space-y-2") do
          Heading(level: 3) { "Claude Code" }
          Codeblock("claude mcp add --transport http ruby-ui https://rubyui.com/mcp", syntax: :shell, clipboard: true)
        end

        # Cursor
        div(class: "space-y-2") do
          Heading(level: 3) { "Cursor" }
          p(class: "text-sm text-foreground/70") { "Add to .cursor/mcp.json:" }
          Codeblock(cursor_config_json, syntax: :json, clipboard: true)
        end

        # Claude Desktop
        div(class: "space-y-2") do
          Heading(level: 3) { "Claude Desktop" }
          p(class: "text-sm text-foreground/70") { "Add to claude_desktop_config.json:" }
          Codeblock(generic_config_json, syntax: :json, clipboard: true)
        end

        # Windsurf
        div(class: "space-y-2") do
          Heading(level: 3) { "Windsurf" }
          p(class: "text-sm text-foreground/70") { "Add to mcp_config.json:" }
          Codeblock(generic_config_json, syntax: :json, clipboard: true)
        end

        # VS Code
        div(class: "space-y-2") do
          Heading(level: 3) { "VS Code" }
          p(class: "text-sm text-foreground/70") { "Add to .vscode/mcp.json:" }
          Codeblock(generic_config_json, syntax: :json, clipboard: true)
        end

        # Zed
        div(class: "space-y-2") do
          Heading(level: 3) { "Zed" }
          p(class: "text-sm text-foreground/70") { "Add to settings.json:" }
          Codeblock(zed_config_json, syntax: :json, clipboard: true)
        end
      end

      # Usage
      div(class: "space-y-4") do
        Heading(level: 2) { "Usage" }
        p(class: "text-foreground/80") { "Once connected, ask your agent questions like:" }
        ul(class: "list-disc list-inside space-y-1 text-foreground/80") do
          li { "Install Button and Dialog from Ruby UI." }
          li { "Show me the source of the Card component." }
          li { "Search Ruby UI for a date input." }
          li { "Audit my Ruby UI install." }
        end
      end

      # Tools
      div(class: "space-y-4") do
        Heading(level: 2) { "Tools" }
        p(class: "text-foreground/80") { "The MCP server exposes the following tools:" }
        div(class: "overflow-x-auto rounded-md border") do
          table(class: "w-full text-sm") do
            thead(class: "border-b bg-muted/50") do
              tr do
                th(class: "px-4 py-3 text-left font-medium") { "Tool" }
                th(class: "px-4 py-3 text-left font-medium") { "Description" }
              end
            end
            tbody do
              tools_list.each_with_index do |(tool, description), i|
                tr(class: i.even? ? "" : "bg-muted/30") do
                  td(class: "px-4 py-3 font-mono text-xs") { tool }
                  td(class: "px-4 py-3 text-foreground/80") { description }
                end
              end
            end
          end
        end
      end

      # Troubleshooting
      div(class: "space-y-4") do
        Heading(level: 2) { "Troubleshooting" }
        ul(class: "list-disc list-inside space-y-2 text-foreground/80") do
          li { "Endpoint must be reachable; corporate proxies may block streamable HTTP." }
          li { "If the agent can't find components, ask it to call get_project_registries first." }
          li { "Run bundle exec rails g ruby_ui:component <Name> only inside a Rails app with ruby_ui in its Gemfile." }
        end
      end
    end
  end

  private

  def cursor_config_json
    <<~JSON
      {
        "mcpServers": {
          "ruby-ui": { "url": "https://rubyui.com/mcp" }
        }
      }
    JSON
  end

  def generic_config_json
    cursor_config_json
  end

  def zed_config_json
    <<~JSON
      {
        "context_servers": {
          "ruby-ui": { "source": "http", "url": "https://rubyui.com/mcp" }
        }
      }
    JSON
  end

  def tools_list
    [
      ["get_project_registries", "Lists available registries."],
      ["list_items_in_registries", "Returns all components with descriptions."],
      ["search_items_in_registries", "Fuzzy search by name, description, or docs."],
      ["view_items_in_registries", "Returns full source files and dependencies."],
      ["get_item_examples_from_registries", "Returns code examples per component."],
      ["get_add_command_for_items", "Returns a validated rails g ruby_ui:component … command."],
      ["get_audit_checklist", "Returns a post-install verification checklist."],
      ["get_install_command_for_project", "Returns commands to bootstrap ruby_ui in a fresh Rails project."]
    ]
  end
end
