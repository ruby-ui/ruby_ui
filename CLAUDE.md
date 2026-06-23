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

## Releasing

A release is **not done** until all four steps below are complete. Skipping the publish, the docs/website reflection, or the git tag leaves the release half-finished.

Decide the bump with SemVer against commits since the last `vX.Y.Z` tag: new backward-compatible features → **minor**; bug fixes / docs only → **patch**. List the range with `git log --oneline vX.Y.Z..HEAD`.

1. **Bump the version (gem).** Edit `RubyUI::VERSION` in `gem/lib/ruby_ui.rb`. Then from each app dir regenerate lockfiles so the path dependency tracks the new version: `gem/Gemfile.lock` and `docs/Gemfile.lock` should both read `ruby_ui (X.Y.Z)`.

2. **Publish the gem to RubyGems.** From `gem/`: `gem build ruby_ui.gemspec` then `gem push ruby_ui-X.Y.Z.gem`. The account has **MFA**, so `gem push` prompts for a one-time password — have the OTP ready (or pass `--otp <CODE>`). Confirm the publishing account is listed in `gem owner ruby_ui` first. Do not commit the built `.gem` artifact.

3. **Reflect the version on the docs website (PR against `main`).** Releases go through a `[Release] vX.Y.Z` PR (main is protected — no direct pushes). The PR bundles, on a `release/vX.Y.Z` branch:
   - the `gem/lib/ruby_ui.rb` bump + both regenerated `Gemfile.lock`s;
   - `docs/app/views/pages/home.rb` — update the home hero badge copy to the headline features (the header version badge reads `RubyUI::VERSION` and updates automatically; do not hardcode it);
   - `mcp/data/registry.json` — rebuild with `cd mcp && bundle exec rake mcp:build` (reads `../gem`, so it picks up the new version).

4. **Tag + GitHub release.** After the release PR merges, tag `vX.Y.Z` on the merge commit, push the tag, and cut the GitHub release. The git tag and the published gem must both exist — publishing the gem without tagging (or vice versa) is an incomplete release.

## Commits & PRs

- Bracketed prefixes (`[Feature]`, `[Bug Fix]`, `[Documentation]`) or scoped conventional (`feat(scope): ...`).
- Imperative, focused commits. Reference issues/PRs as `(#123)`.
- PRs: linked issue, concise description, before/after screenshots for UI changes, explicit test steps.

## Don'ts

- Don't run commands from repo root expecting them to work — `cd gem` or `cd docs` first.
- Don't edit a component without updating its `docs/app/views/docs/<component>.rb` counterpart.
- Don't bump the gem version from `docs/`; `RubyUI::VERSION` lives in `gem/lib/ruby_ui.rb` and the gem is published from `gem/`. (The release PR also reflects the version into `docs/` and `mcp/` — see [Releasing](#releasing).)
- Don't call a release done after only publishing the gem — tag `vX.Y.Z` and reflect the version on the website too.
- Don't commit secrets; each app uses local env config.
