# Plan 004: Migrate Components Batch 3 (dropdown_menu - pagination)

## Goal
Migrate documentation for the third batch of components.

## Components in this batch
- dropdown_menu
- form
- hover_card
- input
- link
- masked_input
- pagination

## Tasks

For each component above:

**Copy file:** `~/dev/linkana/web/app/views/docs/{component}.rb`
**To:** `lib/ruby_ui/{component}/{component}_docs.rb`

Copy content exactly as-is (no modifications needed).

### Specific file mappings:

1. `~/dev/linkana/web/app/views/docs/dropdown_menu.rb` → `lib/ruby_ui/dropdown_menu/dropdown_menu_docs.rb`
2. `~/dev/linkana/web/app/views/docs/form.rb` → `lib/ruby_ui/form/form_docs.rb`
3. `~/dev/linkana/web/app/views/docs/hover_card.rb` → `lib/ruby_ui/hover_card/hover_card_docs.rb`
4. `~/dev/linkana/web/app/views/docs/input.rb` → `lib/ruby_ui/input/input_docs.rb`
5. `~/dev/linkana/web/app/views/docs/link.rb` → `lib/ruby_ui/link/link_docs.rb`
6. `~/dev/linkana/web/app/views/docs/masked_input.rb` → `lib/ruby_ui/masked_input/masked_input_docs.rb`
7. `~/dev/linkana/web/app/views/docs/pagination.rb` → `lib/ruby_ui/pagination/pagination_docs.rb`

## Verification

After completion, verify files exist:
```bash
ls lib/ruby_ui/dropdown_menu/dropdown_menu_docs.rb
ls lib/ruby_ui/form/form_docs.rb
ls lib/ruby_ui/hover_card/hover_card_docs.rb
ls lib/ruby_ui/input/input_docs.rb
ls lib/ruby_ui/link/link_docs.rb
ls lib/ruby_ui/masked_input/masked_input_docs.rb
ls lib/ruby_ui/pagination/pagination_docs.rb
```

Run tests:
```bash
bundle exec rake
```

## After Completion

Update `plans/PROGRESS.md`: Change plan 004 status from "Pending" to "Complete"

## Do Not
- Do not commit changes - ask user first
- Do not modify the web repository yet
