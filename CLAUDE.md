# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

RubyUI is a Ruby gem that provides UI components built on top of the Phlex framework. It's a copy-and-paste component library (not a traditional gem dependency) - users generate components into their Rails apps and own the code.

## Common Commands

```bash
# Run all tests
bundle exec rake test

# Run a single test file
bundle exec ruby -Itest test/ruby_ui/button_test.rb

# Run linter (Standard Ruby)
bundle exec rake standard

# Auto-fix linting issues
bundle exec standardrb --fix

# Run tests and linting (default rake task)
bundle exec rake
```

## Architecture

### Component Structure

Each component lives in `lib/ruby_ui/<component_name>/` and consists of:
- **Ruby files** (`.rb`): Phlex components that inherit from `RubyUI::Base`
- **JavaScript files** (`.js`): Stimulus controllers for interactive behavior

Example: The Dialog component has `dialog.rb`, `dialog_content.rb`, `dialog_trigger.rb`, etc., plus `dialog_controller.js`.

### Base Class (`lib/ruby_ui/base.rb`)

All components inherit from `RubyUI::Base` which:
- Extends `Phlex::HTML`
- Integrates `TailwindMerge` for intelligent Tailwind CSS class merging
- Provides `default_attrs` pattern for component defaults that can be overridden

### Component Pattern

Components follow this pattern:
```ruby
class RubyUI::Button < Base
  def initialize(variant: :primary, size: :md, **attrs)
    @variant = variant
    @size = size
    super(**attrs)  # passes to Base for class merging
  end

  def view_template(&)
    button(**attrs, &)
  end

  private

  def default_attrs
    {type: :button, class: computed_classes}
  end
end
```

### Generators

- `lib/generators/ruby_ui/install/install_generator.rb` - Sets up RubyUI in a Rails app
- `lib/generators/ruby_ui/install/docs_generator.rb` - Installs documentation files to Rails app
- `lib/generators/ruby_ui/component_generator.rb` - Generates individual components
- `lib/generators/ruby_ui/dependencies.yml` - Defines component dependencies (other components, gems, JS packages)

### Documentation Files

Each component can have a documentation file at `lib/ruby_ui/{component}/{component}_docs.rb`. These files:
- Are copied to `app/views/docs/` in Rails apps via `bin/rails g ruby_ui:install:docs`
- Depend on stub classes in `lib/ruby_ui/docs/` (Views::Base, Docs::Header, etc.)
- Are excluded from test autoloading (see `test/test_helper.rb`)

### Testing

Tests use Minitest with a custom `ComponentTest` base class in `test/test_helper.rb`. Components are tested by rendering them with `phlex { RubyUI.ComponentName(...) }` and asserting against the HTML output.
