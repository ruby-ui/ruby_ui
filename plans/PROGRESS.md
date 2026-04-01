# Migration Progress Tracker

---

## Documentation Migration (NEW)

Migrating component documentation from web repo to ruby_ui gem.

**Source:** `~/dev/linkana/web/app/views/docs/`
**Destination:** `lib/ruby_ui/{component}/{component}_docs.rb`

### Documentation Plans

| Plan | Description | Status |
|------|-------------|--------|
| [001-generator-and-button.md](./001-generator-and-button.md) | Create docs generator + button example | Complete |
| [002-components-batch-1.md](./002-components-batch-1.md) | accordion → card (9 components) | Complete |
| [003-components-batch-2.md](./003-components-batch-2.md) | carousel → dialog (10 components) | Complete |
| [004-components-batch-3.md](./004-components-batch-3.md) | dropdown_menu → pagination (7 components) | Complete |
| [005-components-batch-4.md](./005-components-batch-4.md) | popover → sidebar (8 components) | Complete |
| [006-components-batch-5.md](./006-components-batch-5.md) | skeleton → typography (8 components) | Complete |

---

## Component Views Migration (COMPLETED)

Migrated component views from `/Users/cooper/dev/linkana/componentes/` to `lib/ruby_ui/`

**Source:** `/Users/cooper/dev/linkana/componentes/`
**Destination:** `/Users/cooper/dev/linkana/ruby_ui/lib/ruby_ui/`

### Batch Status

| Batch | Components | Status |
|-------|------------|--------|
| 01 | accordion, alert, alert_dialog, aspect_ratio, avatar | Complete |
| 02 | badge, base.rb, breadcrumb, button, calendar | Complete |
| 03 | card, carousel, chart, checkbox, clipboard | Complete |
| 04 | codeblock, collapsible, combobox, command, context_menu | Complete |
| 05 | dialog, dropdown_menu, form, hover_card, input | Complete |
| 06 | link, masked_input, pagination, popover, progress | Complete |
| 07 | radio_button, select, separator, sheet, shortcut_key | Complete |
| 08 | sidebar, skeleton, switch, table, tabs | Complete |
| 09 | textarea, theme_toggle, tooltip, typography | Complete |

---

## Completed Components

- accordion
- alert
- alert_dialog
- aspect_ratio (no source files - empty directory)
- avatar
- badge
- base.rb (added development mode before_template)
- breadcrumb
- button
- calendar (no source files - empty directory)
- card
- carousel (no source files - empty directory)
- chart (no source files - empty directory)
- checkbox (updated border and checked styling)
- clipboard
- codeblock (no changes - source identical to destination)
- collapsible (no source files - empty directory)
- combobox (no changes - destination already more advanced than source)
- command (no source files - empty directory)
- context_menu (no source files - empty directory)
- dialog (no changes - destination already has improvements)
- dropdown_menu (no changes - source identical to destination)
- form (updated with empty:hidden and flex layout)
- hover_card (no changes - source identical to destination)
- input (no changes - destination has improved focus styles)
- link (no changes - destination already has text-primary fix)
- masked_input (no changes - source identical to destination)
- pagination (no changes - source identical to destination)
- popover (no changes - source identical to destination)
- progress (no changes - source identical to destination)
- radio_button (no changes - destination has better dark mode styling)
- select (no changes - source identical to destination)
- separator (no changes - source identical to destination)
- sheet (added overflow-scroll to SheetContent)
- shortcut_key (no changes - source identical to destination)
- sidebar (no changes - source identical to destination)
- skeleton (no source files - empty directory)
- switch (no changes - source identical to destination)
- table (no changes - destination has additional relative class)
- tabs (no changes - source identical to destination)
- textarea (no changes - source identical to destination)
- theme_toggle (no changes - source identical to destination)
- tooltip (no changes - source identical to destination)
- typography (no changes - source identical to destination)

---

## Notes

- Each batch creates one commit per component
- Run `/clear` between batches to manage context
- DO NOT commit this file or the plans/ folder
