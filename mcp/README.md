# ruby_ui-mcp

Model Context Protocol (MCP) server for [Ruby UI](https://rubyui.com). Lets AI coding agents discover, inspect, and install Ruby UI components.

Hosted endpoint: **https://rubyui.com/mcp**

## Tools

| Tool | Purpose |
|------|---------|
| `get_project_registries` | List available registries (always returns `ruby_ui`). |
| `list_items_in_registries` | All components with descriptions. |
| `search_items_in_registries` | Fuzzy search by name, description, or docs. |
| `view_items_in_registries` | Full source + dependencies for given components. |
| `get_item_examples_from_registries` | Code examples per component. |
| `get_add_command_for_items` | Validated `rails g ruby_ui:component …` command. |
| `get_audit_checklist` | Post-install verification checklist. |

## Architecture

- Rails engine gem, sibling of `gem/` and `docs/` in the monorepo.
- Static `data/registry.json` built from `../gem/` by `exe/ruby-ui-mcp-build`, committed to the repo.
- Mounted inside the `docs/` Rails app at `/mcp` via `RubyUI::MCP::Engine`.
- HTTP transport via `mcp` ruby-sdk (`StreamableHTTPTransport`).
- Read-only; component installs happen client-side via the Ruby UI generator.

## Development

```bash
cd mcp
bundle install
bundle exec rake test
```

Rebuild the registry from the sibling gem:

```bash
bundle exec exe/ruby-ui-mcp-build
```

CI verifies the committed `data/registry.json` matches a fresh build (`mcp-registry-check` job).

## Client setup

See https://rubyui.com/docs/mcp for per-client install snippets (Claude Code, Cursor, Claude Desktop, Windsurf, VS Code, Zed).
