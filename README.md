Rails need a plug n play system for creating streamlined ui components.

Phlex looks fun and fast, so I thought I'd start creating ui components with it.

Here is the list of components that are being built. For reference, see here https://ui.shadcn.com/docs/components/accordion

✅ Accordion
✅ Alert
✅ Alert Dialog
✅ Aspect Ratio
✅ Avatar
✅ Badge
✅ Button
✅ Calendar
✅ Card
✅ Checkbox
✅ Codeblock
✅ Collapsible
⚪️ Combobox
✅ Command
⚪️ Context Menu
⚪️ Data Table
✅ Date Picker
✅ Dialog
✅ Dropdown Menu
⚪️ Form
✅ Hover Card
✅ Input
✅ Label
✅ Link
⚪️ Menubar
⚪️ Navigation Menu
✅ Pagination
✅ Popover
⚪️ Progress
⚪️ Radio Group
⚪️ Scroll Area
⚪️ Select
⚪️ Separator
✅ Sheet
⚪️ Skeleton
⚪️ Slider
⚪️ Switch
⚪️ Table
✅ Tabs
✅ Textarea
⚪️ Toast
⚪️ Toggle
✅ Tooltip
✅ Typography

## Contributing - Local Development Setup

### Install the Gem Locally

To contribute to this project, it's recommended to install the gem locally and point to it in your Gemfile:

```ruby
gem "rbui", path: "../rbui"
```

### Link the JavaScript Package

Similarly, link the rbui-js package locally using yarn:

```bash
yarn add ../rbui
```

## Working with Components

### Component Development Workflow

1. Eject the component you want to modify using the generator:
   ```bash
   rails generate rbui:component combobox
   ```
2. Make your desired changes to the ejected component
3. Once you're satisfied with the modifications, integrate the component back into the gem in the appropriate location

This workflow allows you to iterate quickly on components while maintaining the gem's structure.

Would you like me to expand on any part of the contributing guide?
