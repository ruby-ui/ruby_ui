# Ruby UI MCP Server — Design

**Date:** 2026-05-09
**Status:** Approved
**Author:** Djalma Araújo (with Claude)

## Summary

Add a Model Context Protocol (MCP) server for `ruby_ui` so AI coding agents (Claude Code, Cursor, Claude Desktop, Windsurf, VS Code, Zed) can discover, inspect, and install RubyUI components programmatically. Mirrors the shadcn MCP feature set (full 7-tool surface) and is hosted as an HTTP endpoint mounted inside the existing `docs/` Rails 8 app at `https://rubyui.com/mcp`.

## Goals

- Agents can list, search, view, and install RubyUI components without manual file copying or doc reading.
- Agents can verify their install via an audit checklist.
- Zero local install for end users — HTTP transport, paste a URL into client config.
- Single source of truth: the existing `gem/` directory. No duplication.
- Independent release cadence from the `ruby_ui` gem.

## Non-Goals

- Local stdio binary distribution (deferred; HTTP-only for v1).
- Authentication / API keys (registry data is public).
- Multi-registry support (shadcn's primary registry pattern; ruby_ui ships one registry).
- Direct filesystem mutation by the MCP server. Installation is performed by the client agent running `rails g ruby_ui:component …` locally.

## Architecture

### Repo Layout

```
ruby_ui/
├── gem/              # existing — Phlex components, generators
├── docs/             # existing — Rails 8.1 site (rubyui.com)
│   ├── Gemfile                       # adds: gem "ruby_ui-mcp", path: "../mcp"
│   ├── config/routes.rb              # mounts RubyUI::MCP::Engine => "/mcp"
│   ├── app/views/docs/mcp.rb         # NEW MCP docs page
│   ├── app/controllers/docs_controller.rb  # +action :mcp
│   └── app/components/shared/menu.rb # +MCP entry
└── mcp/              # NEW — Rails engine gem
    ├── ruby_ui-mcp.gemspec
    ├── Gemfile
    ├── Rakefile
    ├── lib/ruby_ui/mcp/
    │   ├── version.rb
    │   ├── engine.rb                  # Rails::Engine
    │   ├── server.rb                  # MCP server (modelcontextprotocol/ruby-sdk)
    │   ├── registry.rb                # loads + queries registry.json
    │   ├── tools/                     # one file per MCP tool
    │   │   ├── get_project_registries.rb
    │   │   ├── list_items_in_registries.rb
    │   │   ├── search_items_in_registries.rb
    │   │   ├── view_items_in_registries.rb
    │   │   ├── get_item_examples_from_registries.rb
    │   │   ├── get_add_command_for_items.rb
    │   │   └── get_audit_checklist.rb
    │   └── builders/
    │       └── registry_builder.rb    # reads ../gem, writes registry.json
    ├── data/registry.json             # built artifact, committed
    ├── exe/ruby-ui-mcp-build          # CLI: rebuild registry
    └── test/
```

### Request Flow

```
client (Claude Code, Cursor, etc.)
  ↓ HTTPS POST /mcp (streamable HTTP transport)
docs/ Rails app
  ↓ mount
RubyUI::MCP::Engine
  ↓
RubyUI::MCP::Server (mcp ruby-sdk)
  ↓ tool dispatch
RubyUI::MCP::Tools::*
  ↓ query
RubyUI::MCP::Registry (in-memory, loaded at boot from data/registry.json)
  ↓ JSON-RPC response
client
```

## Registry

### Schema

`mcp/data/registry.json`:

```json
{
  "version": "1.2.0",
  "generated_at": "2026-05-09T12:00:00Z",
  "components": {
    "button": {
      "name": "Button",
      "description": "Trigger actions or events.",
      "files": [
        {"path": "button.rb", "content": "..."},
        {"path": "button_controller.js", "content": "..."}
      ],
      "dependencies": {
        "components": ["Icon"],
        "js_packages": [],
        "gems": []
      },
      "install_command": "rails g ruby_ui:component Button",
      "docs_markdown": "# Button\n\n...",
      "examples": [
        {"title": "Basic", "code": "RubyUI.Button { 'Click' }"}
      ]
    }
  }
}
```

### Builder

`RubyUI::MCP::Builders::RegistryBuilder`:

- Walks `../gem/lib/ruby_ui/*/`.
- Reads all `.rb` and `.js` files per component directory.
- Parses `../gem/lib/generators/ruby_ui/dependencies.yml` for component/JS/gem deps.
- Reads `../gem/lib/ruby_ui/version.rb` for version pin.
- Renders each `_docs.rb` Phlex view to HTML, converts to markdown.
- Extracts `Docs::VisualCodeExample` blocks as `examples`.
- Writes `mcp/data/registry.json` deterministically (sorted keys, stable timestamps optional via env).

### Build Lifecycle

- Local: `bin/rake mcp:build` (wraps `exe/ruby-ui-mcp-build`).
- CI: a `mcp-registry-check` job rebuilds and fails if `git diff` on `data/registry.json` is non-empty. Contributors must commit the regenerated registry when `gem/` changes.
- Deploy: docs/ deploys with the latest committed `registry.json`. No build at deploy time.

## MCP Tools (shadcn parity)

| Tool | Purpose | Inputs | Outputs |
|------|---------|--------|---------|
| `get_project_registries` | List registries available. Single registry `ruby_ui` for client compat. | – | `[{name, url, description}]` |
| `list_items_in_registries` | All components, name + short description. | `registries[]` | `[{name, description}]` |
| `search_items_in_registries` | Fuzzy match name/description/docs. | `query`, `registries[]`, `limit?` | `[{name, description, score}]` |
| `view_items_in_registries` | Full source files + deps. | `items[]` | `[{name, files, dependencies, ...}]` |
| `get_item_examples_from_registries` | Code examples per component. | `items[]` | `[{name, examples}]` |
| `get_add_command_for_items` | Structured install command. | `items[]` | `{generator, components, command_string}` |
| `get_audit_checklist` | Static post-install verification list. | – | `[{check, description}]` |

### Audit Checklist Items

- `ruby_ui` gem present in `Gemfile`.
- Component files exist under `app/components/ruby_ui/<name>/`.
- Stimulus controllers registered (where applicable).
- JS packages from `dependencies.yml` present in `package.json`.
- Tailwind `content` paths include `app/components/ruby_ui/**/*`.
- Zeitwerk loads the `RubyUI` namespace.
- Generated views compile (no Phlex render errors).

## Security

- Component names in `get_add_command_for_items` validated against registry allowlist; regex `\A[A-Z][A-Za-z0-9]*\z`. No shell metacharacters reach the client.
- Output is structured (`{generator, components}`), not a raw shell string. The convenience `command_string` is built from validated tokens.
- MCP server is read-only. No filesystem writes. Execution risk lives in the client (Claude Code, etc.), gated by its own bash-permission layer.
- Tool exception handler returns MCP error without stack traces.

## Hosting

- Mounted in existing `docs/` Rails app at `/mcp`. Subdomain `mcp.rubyui.com` is a future option, not v1.
- Public, no auth.
- `Rack::Attack` rate limit: 60 requests/min/IP on `/mcp/*`.
- Registry loaded once at boot, cached in memory. Reload requires deploy.

## Documentation Page

New `docs/app/views/docs/mcp.rb` modeled after the shadcn MCP docs page.

Sections:

1. **Intro** — what MCP is, what ruby_ui MCP does.
2. **Setup** — tabbed install per client. Each tab is a copy-paste snippet:
   - Claude Code: `claude mcp add --transport http ruby-ui https://rubyui.com/mcp`
   - Cursor: `.cursor/mcp.json` JSON
   - Claude Desktop: `claude_desktop_config.json` JSON
   - Windsurf: `mcp_config.json` JSON
   - VS Code: `.vscode/mcp.json` JSON
   - Zed: `settings.json` snippet
3. **Usage** — example agent prompts ("Install Button and Dialog", "Show me Card source", "Search for date input", "Audit my install").
4. **Tools reference** — table of all 7 tools with params and examples.
5. **Troubleshooting** — common errors.

Wiring:

- Route added to `docs/config/routes.rb` under existing docs scope.
- Action added to `DocsController`.
- Menu entry in `app/components/shared/menu.rb`.

## Versioning

- `mcp/lib/ruby_ui/mcp/version.rb` is independent of `gem/lib/ruby_ui/version.rb`.
- Registry embeds the gem version it was built from (`registry.version`).
- Tool responses include `gem_version` so agents know what they're consuming.

## Testing

- Minitest, mirrors `gem/` test style.
- Per-tool tests with a stub in-memory registry.
- Builder integration test against a small fixture gem directory.
- Server smoke test via an in-process MCP client.
- CI job: `cd mcp && bundle exec rake` (tests + standardrb).
- CI job: `mcp-registry-check` — rebuild registry, fail on diff.

## Error Handling

- Unknown component name → MCP error with top-3 fuzzy suggestions.
- Malformed args → JSON-RPC `InvalidParams`.
- Registry load failure at boot → Rails fails fast.
- Tool exceptions → caught, logged, returned as MCP error without stack traces.

## Logging

- Rails logger tagged `[MCP]`.
- Per request: tool name, arg count, latency, status.
- No component source in logs; names only.

## Out of Scope (Future Work)

- Local stdio gem distribution (`gem install ruby_ui-mcp && ruby-ui-mcp`).
- Hosted subdomain `mcp.rubyui.com`.
- API keys / higher-tier rate limits.
- Per-version registry serving (`?version=1.2.0`).
- Telemetry / metrics dashboards.
