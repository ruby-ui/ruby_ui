# RubyUI

[![CI](https://github.com/ruby-ui/ruby_ui/actions/workflows/ci.yml/badge.svg)](https://github.com/ruby-ui/ruby_ui/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/ruby_ui.svg)](https://rubygems.org/gems/ruby_ui)

Beautifully designed components that you can copy and paste into your apps. Accessible. Customizable. Open Source.

This repository is a **monorepo** with two sibling projects:

```
ruby_ui/
├── gem/    # the ruby_ui gem (lib/, generators, tests, gemspec)
└── docs/   # the Rails app that powers https://rubyui.com
```

## Quick links

- **Use the gem in your app:** see [`gem/README.md`](gem/README.md).
- **Documentation site:** https://rubyui.com/docs/introduction
- **Contributing guide:** [`CONTRIBUTING.md`](CONTRIBUTING.md)

## Layout

| Path | What lives here |
| --- | --- |
| [`gem/`](gem/) | The `ruby_ui` gem (`gem build`, `gem release` from this folder). |
| [`docs/`](docs/) | Rails 8 app for the documentation site. Consumes the local gem via `path: "../gem"`. |
| [`.github/workflows/ci.yml`](.github/workflows/ci.yml) | Unified CI: gem tests on Ruby 3.3 + 3.4, Rails docs app tests, and a docker-build job that publishes the docs devcontainer to ghcr.io. |

## Development

The two projects are independent for everyday work — pick the one you need:

```bash
# Gem work
cd gem
bundle install
bundle exec rake          # tests + standardrb

# Docs work (consumes the local gem via path: "../gem")
cd docs
bundle install
pnpm install
bin/dev                   # http://localhost:3000
```

Editing files under `gem/lib/ruby_ui/` is reflected immediately when running the docs app — no `bundle update`, no rebuild, no PR coordination across two repos.

## License

Released under the [MIT License](gem/LICENSE.txt).
