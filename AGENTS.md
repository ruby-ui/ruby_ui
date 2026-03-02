# AGENTS.md

This file provides guidance to AI coding agents when working with code in this repository.

## Project Overview

RubyUI is a Ruby gem providing a collection of Phlex-based UI components for Rails applications. It follows a copy-and-paste distribution model (not imported as a runtime dependency). Components use Phlex for rendering, Tailwind CSS for styling (merged via `tailwind_merge`), and Stimulus.js controllers for interactivity.

- **Version:** defined in `lib/ruby_ui.rb`
- **Ruby requirement:** >= 3.2
- **Docs:** https://rubyui.com/docs/introduction

## Commands

```bash
# Run all tests + linter (default rake task)
bundle exec rake

# Tests only
bundle exec rake test

# Single test file
bundle exec rake test TEST=test/ruby_ui/button_test.rb

# Linter (StandardRB)
bundle exec rake standard

# Auto-fix lint issues
bundle exec standardrb --fix
```

## Architecture

### Component Pattern

Every component extends `RubyUI::Base < Phlex::HTML` (`lib/ruby_ui/base.rb`). Base provides:
- `default_attrs` — override to set default HTML attributes/Tailwind classes
- `@attrs` — merged user attrs + defaults, with Tailwind classes intelligently merged via `TailwindMerge::Merger`
- Phlex `mix` helper combines attribute hashes

Typical component structure in `lib/ruby_ui/<component_name>/`:
- `<component>.rb` — the component class with `view_template` method
- `<component>_docs.rb` — documentation/usage examples (excluded from tests)
- `<component>_controller.js` — optional Stimulus controller for interactivity

Components use Phlex DSL for rendering (e.g., `button(**attrs, &)` in `view_template`). Variants are handled through initializer params that map to different Tailwind class sets.

### Test Pattern

Tests use **Minitest** and extend `ComponentTest` (defined in `test/test_helper.rb`). The `phlex` helper renders components to HTML strings for assertion:

```ruby
class RubyUI::ButtonTest < ComponentTest
  def test_render_with_all_items
    output = phlex { RubyUI.Button(variant: :primary) { "Primary" } }
    assert_match(/Primary/, output)
  end
end
```

Components are invoked via `RubyUI.<ComponentName>()` through Phlex::Kit.

### Generator System

Rails generators in `lib/generators/ruby_ui/` handle installation into consumer apps:
- `ruby_ui:install` — sets up base component, dependencies, initializer
- `ruby_ui:component <Name>` — copies a specific component into the app
- `ruby_ui:component:all` — copies all components
- `dependencies.yml` — maps each component to its required gems, JS packages, and other components

### JavaScript

Stimulus controllers live alongside their Ruby components. JS dependencies (Chart.js, Embla, Floating UI, etc.) are declared in `package.json` and mapped per-component in `dependencies.yml`.

## CI

GitHub Actions (`.github/workflows/ci.yml`) runs `rake test` and `rake standard` against Ruby 3.3 and 3.4 on every push to main and on PRs.

## PR Template

PRs should be prefixed with a category in brackets (e.g., `[Feature]`, `[Bug Fix]`), reference a related issue, include a description with before/after screenshots if applicable, and provide testing instructions.
