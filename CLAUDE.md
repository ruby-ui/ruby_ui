# CLAUDE.md

Guidance for AI agents working at the root of the `ruby-ui/ruby_ui` monorepo.

## Layout

Two sibling projects, each independent (own `Gemfile`, `package.json`, tests, lockfiles):

| Path | What it is |
| --- | --- |
| [`gem/`](gem/) | The `ruby_ui` gem — Phlex components, generators, gemspec, Minitest suite. Published to RubyGems from here. |
| [`docs/`](docs/) | Rails 8 app powering https://rubyui.com. Consumes the local gem via `path: "../gem"`. |
| `.github/workflows/ci.yml` | Unified CI: gem tests (Ruby 3.3 + 3.4), docs Rails tests, docker build for docs devcontainer. |

Subproject-specific instructions live in `gem/AGENTS.md` and `docs/CLAUDE.md` (→ `docs/AGENTS.md`). Read those before editing inside a subdir.

## Routing changes

- Component code → `gem/lib/ruby_ui/<component>/`. Tests → `gem/test/ruby_ui/<component>_test.rb`.
- Component docs view → `docs/app/views/docs/<component>.rb`. Update in same PR as the component.
- Generator/installer logic → `gem/lib/generators/ruby_ui/`. Dependency map → `gem/lib/generators/ruby_ui/dependencies.yml`.
- Site chrome, routes, marketing pages → `docs/app/`.

## Common commands

Run from the relevant subdir, not root.

```bash
# Gem
cd gem
bundle exec rake                                  # tests + standardrb
bundle exec rake test TEST=test/ruby_ui/button_test.rb
bundle exec standardrb --fix

# Docs site
cd docs
bin/setup
bin/dev                                           # local server
pnpm build && pnpm build:css                      # assets
bin/rails db:test:prepare test
bundle exec standardrb
```

## Conventions

- Ruby 3.2+, 2-space indent, `snake_case` files/methods, `CamelCase` classes. StandardRB enforced.
- Components extend `RubyUI::Base < Phlex::HTML`; classes merged via `tailwind_merge`. Invoke as `RubyUI.<Name>()` (Phlex::Kit).
- Stimulus controllers colocated with components: `<component>_controller.js`. JS deps declared in `gem/package.json` and per-component in `dependencies.yml`.
- Tests extend `ComponentTest`; render via `phlex { ... }` helper.

## Commits & PRs

- Bracketed prefixes (`[Feature]`, `[Bug Fix]`, `[Documentation]`) or scoped conventional (`feat(scope): ...`).
- Imperative, focused commits. Reference issues/PRs as `(#123)`.
- PRs: linked issue, concise description, before/after screenshots for UI changes, explicit test steps.

## Don'ts

- Don't run commands from repo root expecting them to work — `cd gem` or `cd docs` first.
- Don't edit a component without updating its `docs/app/views/docs/<component>.rb` counterpart.
- Don't bump the gem version or release from `docs/`; releases happen in `gem/`.
- Don't commit secrets; each app uses local env config.
