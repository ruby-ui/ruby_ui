# Batch 07: radio_button, select, separator, sheet, shortcut_key

## Components in this Batch

### 1. radio_button
- **Source:** `componentes/views/radio_button/`
- **JS:** None
- **Files:** radio_button.rb
- **Commit:** "Update radio_button component"

### 2. select
- **Source:** `componentes/views/select/`
- **JS:** `componentes/js/select_controller.js`, `componentes/js/select_item_controller.js`
- **Files:** select.rb, select_content.rb, select_group.rb, select_input.rb, select_item.rb, select_label.rb, select_trigger.rb, select_value.rb
- **Commit:** "Update select component"

### 3. separator
- **Source:** `componentes/views/separator/`
- **JS:** None
- **Files:** separator.rb
- **Commit:** "Update separator component"

### 4. sheet
- **Source:** `componentes/views/sheet/`
- **JS:** `componentes/js/sheet_controller.js`, `componentes/js/sheet_content_controller.js`
- **Files:** sheet.rb, sheet_content.rb, sheet_description.rb, sheet_footer.rb, sheet_header.rb, sheet_middle.rb, sheet_title.rb, sheet_trigger.rb
- **Commit:** "Update sheet component"

### 5. shortcut_key
- **Source:** `componentes/views/shortcut_key/`
- **JS:** None
- **Files:** shortcut_key.rb
- **Commit:** "Update shortcut_key component"

## Execution Steps

For each component:
1. Read all `.rb` files from source folder
2. Read JS controller if exists
3. Write each file to destination `lib/ruby_ui/<component>/`
4. Stage: `git add lib/ruby_ui/<component>/`
5. Commit: `git commit -m "Update <component> component"`

After completing all 5 components, update PROGRESS.md to mark Batch 07 as Complete.
