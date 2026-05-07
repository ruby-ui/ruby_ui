# Contributing to RubyUI

Thanks for your interest in contributing! This repository is a monorepo containing two sibling projects:

- [`gem/`](gem/) — the `ruby_ui` gem published to rubygems.org.
- [`docs/`](docs/) — the Rails app that powers https://rubyui.com.

The big advantage of the monorepo: **a single PR can touch both the component and the docs example**. The docs app consumes the local gem via `path: "../gem"`, so any change in `gem/lib/ruby_ui/` is reflected in the running site immediately.

## Development setup

We recommend using the devcontainer for either subproject (each has its own `.devcontainer/`).

```bash
git clone git@github.com:ruby-ui/ruby_ui.git
cd ruby_ui

# For gem-only work:
cd gem
bundle install
bundle exec rake

# For docs work:
cd docs
bundle install
pnpm install
bin/dev
```

## Workflow

1. Fork and create a feature branch.
2. Make your changes:
   - Component or generator changes → `gem/lib/...`, with tests in `gem/test/...`.
   - Documentation page changes → `docs/app/views/docs/...` or `docs/app/components/...`.
   - If a component change affects how it's documented, update **both** in the same PR.
3. Run the relevant test suites:
   - `cd gem && bundle exec rake` (tests + standardrb).
   - `cd docs && bin/rails test` and `bundle exec standardrb`.
4. Open a Pull Request against `main`. Use the PR template and prefix the title with a category in brackets, e.g. `[Feature] Add new variant to Button`.

## Focus areas

We prioritize:

- Improving existing components rather than adding new ones.
- Preserving the shadcn look and feel.
- Enhancing documentation.
- Fixing bugs.

## Code style

- Ruby: [Standard Ruby](https://github.com/standardrb/standard) — `bundle exec standardrb --fix` to auto-fix.
- JavaScript: kept minimal; Stimulus controllers live alongside the components they belong to.

## Documentation files

The gem ships per-component `*_docs.rb` files (rendering examples) under `gem/lib/ruby_ui/<component>/`. Consumers of the gem can install these into their own Rails app with:

```bash
bin/rails g ruby_ui:install:docs
```

Within this monorepo, the **docs app does not run that generator** — it has its own richer view implementations in `docs/app/views/docs/` and `docs/app/components/docs/`. If you change a component's API, update the relevant view in `docs/app/views/docs/<component>.rb` to keep the documentation site accurate.

Thanks for helping make RubyUI better!
