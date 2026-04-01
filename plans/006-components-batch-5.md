# Plan 006: Migrate Components Batch 5 (skeleton - typography)

## Goal
Migrate documentation for the final batch of components.

## Components in this batch
- skeleton
- switch
- table
- tabs
- textarea
- theme_toggle
- tooltip
- typography

## Tasks

For each component above:

**Copy file:** `~/dev/linkana/web/app/views/docs/{component}.rb`
**To:** `lib/ruby_ui/{component}/{component}_docs.rb`

Copy content exactly as-is (no modifications needed).

### Specific file mappings:

1. `~/dev/linkana/web/app/views/docs/skeleton.rb` → `lib/ruby_ui/skeleton/skeleton_docs.rb`
2. `~/dev/linkana/web/app/views/docs/switch.rb` → `lib/ruby_ui/switch/switch_docs.rb`
3. `~/dev/linkana/web/app/views/docs/table.rb` → `lib/ruby_ui/table/table_docs.rb`
4. `~/dev/linkana/web/app/views/docs/tabs.rb` → `lib/ruby_ui/tabs/tabs_docs.rb`
5. `~/dev/linkana/web/app/views/docs/textarea.rb` → `lib/ruby_ui/textarea/textarea_docs.rb`
6. `~/dev/linkana/web/app/views/docs/theme_toggle.rb` → `lib/ruby_ui/theme_toggle/theme_toggle_docs.rb`
7. `~/dev/linkana/web/app/views/docs/tooltip.rb` → `lib/ruby_ui/tooltip/tooltip_docs.rb`
8. `~/dev/linkana/web/app/views/docs/typography.rb` → `lib/ruby_ui/typography/typography_docs.rb`

## Verification

After completion, verify files exist:
```bash
ls lib/ruby_ui/skeleton/skeleton_docs.rb
ls lib/ruby_ui/switch/switch_docs.rb
ls lib/ruby_ui/table/table_docs.rb
ls lib/ruby_ui/tabs/tabs_docs.rb
ls lib/ruby_ui/textarea/textarea_docs.rb
ls lib/ruby_ui/theme_toggle/theme_toggle_docs.rb
ls lib/ruby_ui/tooltip/tooltip_docs.rb
ls lib/ruby_ui/typography/typography_docs.rb
```

Run tests:
```bash
bundle exec rake
```

## After Completion

Update `plans/PROGRESS.md`: Change plan 006 status from "Pending" to "Complete"

## Do Not
- Do not commit changes - ask user first
- Do not modify the web repository yet
