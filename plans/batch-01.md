# Batch 01: accordion, alert, alert_dialog, aspect_ratio, avatar

## Instructions

Execute the migration for these 5 components. For each component:
1. Copy all `.rb` files from source to destination (overwrite existing)
2. Copy JS controller if it exists
3. Create a git commit for each component

**Source base:** `/Users/cooper/dev/linkana/componentes/`
**Destination base:** `/Users/cooper/dev/linkana/ruby_ui/lib/ruby_ui/`

---

## Component 1: accordion

**Source files to copy:**
- `componentes/views/accordion/accordion.rb` → `lib/ruby_ui/accordion/accordion.rb`
- `componentes/views/accordion/accordion_content.rb` → `lib/ruby_ui/accordion/accordion_content.rb`
- `componentes/views/accordion/accordion_default_content.rb` → `lib/ruby_ui/accordion/accordion_default_content.rb`
- `componentes/views/accordion/accordion_default_trigger.rb` → `lib/ruby_ui/accordion/accordion_default_trigger.rb`
- `componentes/views/accordion/accordion_icon.rb` → `lib/ruby_ui/accordion/accordion_icon.rb`
- `componentes/views/accordion/accordion_item.rb` → `lib/ruby_ui/accordion/accordion_item.rb`
- `componentes/views/accordion/accordion_trigger.rb` → `lib/ruby_ui/accordion/accordion_trigger.rb`

**JS controller:**
- `componentes/js/accordion_controller.js` → `lib/ruby_ui/accordion/accordion_controller.js`

**Commit:** `git add lib/ruby_ui/accordion/ && git commit -m "Update accordion component"`

---

## Component 2: alert

**Source files to copy:**
- `componentes/views/alert/alert.rb` → `lib/ruby_ui/alert/alert.rb`
- `componentes/views/alert/alert_description.rb` → `lib/ruby_ui/alert/alert_description.rb`
- `componentes/views/alert/alert_title.rb` → `lib/ruby_ui/alert/alert_title.rb`

**JS controller:** None

**Commit:** `git add lib/ruby_ui/alert/ && git commit -m "Update alert component"`

---

## Component 3: alert_dialog

**Source files to copy:**
- `componentes/views/alert_dialog/alert_dialog.rb` → `lib/ruby_ui/alert_dialog/alert_dialog.rb`
- `componentes/views/alert_dialog/alert_dialog_action.rb` → `lib/ruby_ui/alert_dialog/alert_dialog_action.rb`
- `componentes/views/alert_dialog/alert_dialog_cancel.rb` → `lib/ruby_ui/alert_dialog/alert_dialog_cancel.rb`
- `componentes/views/alert_dialog/alert_dialog_content.rb` → `lib/ruby_ui/alert_dialog/alert_dialog_content.rb`
- `componentes/views/alert_dialog/alert_dialog_description.rb` → `lib/ruby_ui/alert_dialog/alert_dialog_description.rb`
- `componentes/views/alert_dialog/alert_dialog_footer.rb` → `lib/ruby_ui/alert_dialog/alert_dialog_footer.rb`
- `componentes/views/alert_dialog/alert_dialog_header.rb` → `lib/ruby_ui/alert_dialog/alert_dialog_header.rb`
- `componentes/views/alert_dialog/alert_dialog_title.rb` → `lib/ruby_ui/alert_dialog/alert_dialog_title.rb`
- `componentes/views/alert_dialog/alert_dialog_trigger.rb` → `lib/ruby_ui/alert_dialog/alert_dialog_trigger.rb`

**JS controller:**
- `componentes/js/alert_dialog_controller.js` → `lib/ruby_ui/alert_dialog/alert_dialog_controller.js`

**Commit:** `git add lib/ruby_ui/alert_dialog/ && git commit -m "Update alert_dialog component"`

---

## Component 4: aspect_ratio

**Source files to copy:** Check `componentes/views/aspect_ratio/` for all `.rb` files

**JS controller:** None

**Commit:** `git add lib/ruby_ui/aspect_ratio/ && git commit -m "Update aspect_ratio component"`

---

## Component 5: avatar

**Source files to copy:**
- `componentes/views/avatar/avatar.rb` → `lib/ruby_ui/avatar/avatar.rb`
- `componentes/views/avatar/avatar_fallback.rb` → `lib/ruby_ui/avatar/avatar_fallback.rb`
- `componentes/views/avatar/avatar_image.rb` → `lib/ruby_ui/avatar/avatar_image.rb`

**JS controller:** None

**Commit:** `git add lib/ruby_ui/avatar/ && git commit -m "Update avatar component"`

---

## After Completion

Update `plans/PROGRESS.md`: Change Batch 01 status from "Pending" to "Complete"
