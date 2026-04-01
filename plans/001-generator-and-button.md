# Plan 001: Create Docs Generator and Button Documentation

## Goal
Create the documentation system infrastructure and migrate the button component as proof of concept.

## Tasks

### Task 1: Create the Docs Generator

**Create file:** `lib/generators/ruby_ui/install/docs_generator.rb`

```ruby
# frozen_string_literal: true

require "rails/generators"

module RubyUI
  module Generators
    module Install
      class DocsGenerator < Rails::Generators::Base
        namespace "ruby_ui:install:docs"
        source_root File.expand_path("../../../ruby_ui", __dir__)
        class_option :force, type: :boolean, default: false

        def copy_docs_files
          say "Installing RubyUI documentation files..."

          docs_file_paths.each do |source_path|
            dest_filename = File.basename(source_path).sub("_docs", "")
            copy_file source_path, Rails.root.join("app/views/docs", dest_filename), force: options["force"]
          end

          say ""
          say "Documentation installed to app/views/docs/", :green
        end

        private

        def docs_file_paths
          Dir.glob(File.join(self.class.source_root, "*", "*_docs.rb"))
        end
      end
    end
  end
end
```

### Task 2: Create Button Documentation

**Copy file:** `~/dev/linkana/web/app/views/docs/button.rb`
**To:** `lib/ruby_ui/button/button_docs.rb`

Copy the content exactly as-is (no modifications needed).

### Task 3: Run Tests

```bash
bundle exec rake
```

Ensure tests pass before asking user about commit.

## Verification

After completion:
1. File exists: `lib/generators/ruby_ui/install/docs_generator.rb`
2. File exists: `lib/ruby_ui/button/button_docs.rb`
3. Tests pass: `bundle exec rake`

## After Completion

Update `plans/PROGRESS.md`: Change plan 001 status from "Pending" to "Complete"

## Do Not
- Do not commit changes - ask user first
- Do not modify the web repository yet
