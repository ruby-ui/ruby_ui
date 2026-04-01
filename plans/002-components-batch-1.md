# Plan 002: Migrate Components Batch 1 (accordion - card)

## Goal
Migrate documentation for the first batch of components.

## Components in this batch
- accordion
- alert
- alert_dialog
- aspect_ratio
- avatar
- badge
- breadcrumb
- calendar
- card

## Tasks

For each component above:

**Copy file:** `~/dev/linkana/web/app/views/docs/{component}.rb`
**To:** `lib/ruby_ui/{component}/{component}_docs.rb`

Copy content exactly as-is (no modifications needed).

### Specific file mappings:

1. `~/dev/linkana/web/app/views/docs/accordion.rb` → `lib/ruby_ui/accordion/accordion_docs.rb`
2. `~/dev/linkana/web/app/views/docs/alert.rb` → `lib/ruby_ui/alert/alert_docs.rb`
3. `~/dev/linkana/web/app/views/docs/alert_dialog.rb` → `lib/ruby_ui/alert_dialog/alert_dialog_docs.rb`
4. `~/dev/linkana/web/app/views/docs/aspect_ratio.rb` → `lib/ruby_ui/aspect_ratio/aspect_ratio_docs.rb`
5. `~/dev/linkana/web/app/views/docs/avatar.rb` → `lib/ruby_ui/avatar/avatar_docs.rb`
6. `~/dev/linkana/web/app/views/docs/badge.rb` → `lib/ruby_ui/badge/badge_docs.rb`
7. `~/dev/linkana/web/app/views/docs/breadcrumb.rb` → `lib/ruby_ui/breadcrumb/breadcrumb_docs.rb`
8. `~/dev/linkana/web/app/views/docs/calendar.rb` → `lib/ruby_ui/calendar/calendar_docs.rb`
9. `~/dev/linkana/web/app/views/docs/card.rb` → `lib/ruby_ui/card/card_docs.rb`

## Verification

After completion, verify files exist:
```bash
ls lib/ruby_ui/accordion/accordion_docs.rb
ls lib/ruby_ui/alert/alert_docs.rb
ls lib/ruby_ui/alert_dialog/alert_dialog_docs.rb
ls lib/ruby_ui/aspect_ratio/aspect_ratio_docs.rb
ls lib/ruby_ui/avatar/avatar_docs.rb
ls lib/ruby_ui/badge/badge_docs.rb
ls lib/ruby_ui/breadcrumb/breadcrumb_docs.rb
ls lib/ruby_ui/calendar/calendar_docs.rb
ls lib/ruby_ui/card/card_docs.rb
```

Run tests:
```bash
bundle exec rake
```

## After Completion

Update `plans/PROGRESS.md`: Change plan 002 status from "Pending" to "Complete"

## Do Not
- Do not commit changes - ask user first
- Do not modify the web repository yet
