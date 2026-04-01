# Plan 003: Migrate Components Batch 2 (carousel - dialog)

## Goal
Migrate documentation for the second batch of components.

## Components in this batch
- carousel
- chart
- checkbox
- clipboard
- codeblock
- collapsible
- combobox
- command
- context_menu
- dialog

## Tasks

For each component above:

**Copy file:** `~/dev/linkana/web/app/views/docs/{component}.rb`
**To:** `lib/ruby_ui/{component}/{component}_docs.rb`

Copy content exactly as-is (no modifications needed).

### Specific file mappings:

1. `~/dev/linkana/web/app/views/docs/carousel.rb` → `lib/ruby_ui/carousel/carousel_docs.rb`
2. `~/dev/linkana/web/app/views/docs/chart.rb` → `lib/ruby_ui/chart/chart_docs.rb`
3. `~/dev/linkana/web/app/views/docs/checkbox.rb` → `lib/ruby_ui/checkbox/checkbox_docs.rb`
4. `~/dev/linkana/web/app/views/docs/clipboard.rb` → `lib/ruby_ui/clipboard/clipboard_docs.rb`
5. `~/dev/linkana/web/app/views/docs/codeblock.rb` → `lib/ruby_ui/codeblock/codeblock_docs.rb`
6. `~/dev/linkana/web/app/views/docs/collapsible.rb` → `lib/ruby_ui/collapsible/collapsible_docs.rb`
7. `~/dev/linkana/web/app/views/docs/combobox.rb` → `lib/ruby_ui/combobox/combobox_docs.rb`
8. `~/dev/linkana/web/app/views/docs/command.rb` → `lib/ruby_ui/command/command_docs.rb`
9. `~/dev/linkana/web/app/views/docs/context_menu.rb` → `lib/ruby_ui/context_menu/context_menu_docs.rb`
10. `~/dev/linkana/web/app/views/docs/dialog.rb` → `lib/ruby_ui/dialog/dialog_docs.rb`

## Verification

After completion, verify files exist:
```bash
ls lib/ruby_ui/carousel/carousel_docs.rb
ls lib/ruby_ui/chart/chart_docs.rb
ls lib/ruby_ui/checkbox/checkbox_docs.rb
ls lib/ruby_ui/clipboard/clipboard_docs.rb
ls lib/ruby_ui/codeblock/codeblock_docs.rb
ls lib/ruby_ui/collapsible/collapsible_docs.rb
ls lib/ruby_ui/combobox/combobox_docs.rb
ls lib/ruby_ui/command/command_docs.rb
ls lib/ruby_ui/context_menu/context_menu_docs.rb
ls lib/ruby_ui/dialog/dialog_docs.rb
```

Run tests:
```bash
bundle exec rake
```

## After Completion

Update `plans/PROGRESS.md`: Change plan 003 status from "Pending" to "Complete"

## Do Not
- Do not commit changes - ask user first
- Do not modify the web repository yet
