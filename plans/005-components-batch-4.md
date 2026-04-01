# Plan 005: Migrate Components Batch 4 (popover - sidebar)

## Goal
Migrate documentation for the fourth batch of components.

## Components in this batch
- popover
- progress
- radio_button
- select
- separator
- sheet
- shortcut_key
- sidebar

## Tasks

For each component above:

**Copy file:** `~/dev/linkana/web/app/views/docs/{component}.rb`
**To:** `lib/ruby_ui/{component}/{component}_docs.rb`

Copy content exactly as-is (no modifications needed).

### Specific file mappings:

1. `~/dev/linkana/web/app/views/docs/popover.rb` → `lib/ruby_ui/popover/popover_docs.rb`
2. `~/dev/linkana/web/app/views/docs/progress.rb` → `lib/ruby_ui/progress/progress_docs.rb`
3. `~/dev/linkana/web/app/views/docs/radio_button.rb` → `lib/ruby_ui/radio_button/radio_button_docs.rb`
4. `~/dev/linkana/web/app/views/docs/select.rb` → `lib/ruby_ui/select/select_docs.rb`
5. `~/dev/linkana/web/app/views/docs/separator.rb` → `lib/ruby_ui/separator/separator_docs.rb`
6. `~/dev/linkana/web/app/views/docs/sheet.rb` → `lib/ruby_ui/sheet/sheet_docs.rb`
7. `~/dev/linkana/web/app/views/docs/shortcut_key.rb` → `lib/ruby_ui/shortcut_key/shortcut_key_docs.rb`
8. `~/dev/linkana/web/app/views/docs/sidebar.rb` → `lib/ruby_ui/sidebar/sidebar_docs.rb`

## Verification

After completion, verify files exist:
```bash
ls lib/ruby_ui/popover/popover_docs.rb
ls lib/ruby_ui/progress/progress_docs.rb
ls lib/ruby_ui/radio_button/radio_button_docs.rb
ls lib/ruby_ui/select/select_docs.rb
ls lib/ruby_ui/separator/separator_docs.rb
ls lib/ruby_ui/sheet/sheet_docs.rb
ls lib/ruby_ui/shortcut_key/shortcut_key_docs.rb
ls lib/ruby_ui/sidebar/sidebar_docs.rb
```

Run tests:
```bash
bundle exec rake
```

## After Completion

Update `plans/PROGRESS.md`: Change plan 005 status from "Pending" to "Complete"

## Do Not
- Do not commit changes - ask user first
- Do not modify the web repository yet
