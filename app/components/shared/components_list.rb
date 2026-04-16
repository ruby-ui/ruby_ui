# frozen_string_literal: true

module Components
  module Shared
    module ComponentsList
      def components
        [
          {name: "Accordion", path: docs_accordion_path},
          {name: "Alert", path: docs_alert_path},
          {name: "Alert Dialog", path: docs_alert_dialog_path},
          {name: "Aspect Ratio", path: docs_aspect_ratio_path},
          {name: "Avatar", path: docs_avatar_path},
          {name: "Badge", path: docs_badge_path},
          {name: "Breadcrumb", path: docs_breadcrumb_path},
          {name: "Button", path: docs_button_path},
          {name: "Calendar", path: docs_calendar_path},
          {name: "Card", path: docs_card_path},
          {name: "Carousel", path: docs_carousel_path},
          # { name: "Chart", path: docs_chart_path },
          {name: "Checkbox", path: docs_checkbox_path},
          {name: "Checkbox Group", path: docs_checkbox_group_path},
          {name: "Clipboard", path: docs_clipboard_path},
          {name: "Codeblock", path: docs_codeblock_path},
          {name: "Collapsible", path: docs_collapsible_path},
          {name: "Combobox", path: docs_combobox_path},
          {name: "Command", path: docs_command_path},
          {name: "Context Menu", path: docs_context_menu_path},
          {name: "Date Picker", path: docs_date_picker_path},
          {name: "Dialog / Modal", path: docs_dialog_path},
          {name: "Dropdown Menu", path: docs_dropdown_menu_path},
          {name: "Form", path: docs_form_path},
          {name: "Hover Card", path: docs_hover_card_path},
          {name: "Input", path: docs_input_path},
          {name: "Link", path: docs_link_path},
          {name: "Masked Input", path: masked_input_path},
          {name: "Pagination", path: docs_pagination_path},
          {name: "Popover", path: docs_popover_path},
          {name: "Progress", path: docs_progress_path},
          {name: "Radio Button", path: docs_radio_button_path},
          {name: "Native Select", path: docs_native_select_path},
          {name: "Select", path: docs_select_path},
          {name: "Separator", path: docs_separator_path},
          {name: "Sheet", path: docs_sheet_path},
          {name: "Shortcut Key", path: docs_shortcut_key_path},
          {name: "Sidebar", path: docs_sidebar_path},
          {name: "Skeleton", path: docs_skeleton_path},
          {name: "Switch", path: docs_switch_path},
          {name: "Table", path: docs_table_path},
          {name: "Tabs", path: docs_tabs_path},
          {name: "Textarea", path: docs_textarea_path},
          {name: "Theme Toggle", path: docs_theme_toggle_path},
          {name: "Tooltip", path: docs_tooltip_path},
          {name: "Typography", path: docs_typography_path}
        ]
      end
    end
  end
end
