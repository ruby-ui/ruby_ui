# frozen_string_literal: true

module Components
  module Shared
    class Menu < Components::Base
      def view_template
        div(class: "pb-4") do
          # Main routes (Docs, Components, Themes, Github, Discord, Twitter)
          div(class: "md:hidden") do
            main_link("Docs", docs_introduction_path)
            main_link("Components", docs_accordion_path)
            main_link("Themes", theme_path("default"))
            main_link("Github", "https://github.com/PhlexUI/phlex_ui")
            main_link("Discord", ENV["DISCORD_INVITE_LINK"])
            main_link("Twitter", ENV["PHLEXUI_TWITTER_LINK"])
          end

          # GETTING STARTED
          h4(class: "mb-1 mt-4 rounded-md px-2 py-1 text-sm font-semibold") { "Getting Started" }
          div(class: "grid grid-flow-row auto-rows-max text-sm") do
            getting_started_links.each do |getting_started|
              menu_link(getting_started)
            end
          end

          # INSTALLATION
          h4(class: "mb-1 mt-4 rounded-md px-2 py-1 text-sm font-semibold") { "Installation" }
          div(class: "grid grid-flow-row auto-rows-max text-sm") do
            installation_links.each do |installation|
              menu_link(installation)
            end
          end

          # COMPONENTS
          h4(class: "mb-1 mt-4 rounded-md px-2 py-1 text-sm font-semibold flex items-center gap-x-2") do
            plain "Components"
            Badge(variant: :primary, size: :sm) { components.count.to_s }
          end
          div(class: "grid grid-flow-row auto-rows-max text-sm") do
            components.each do |component|
              menu_link(component)
            end
          end
        end
      end

      def getting_started_links
        [
          {name: "Introduction", path: docs_introduction_path},
          {name: "Installation", path: docs_installation_path},
          {name: "Dark mode", path: docs_dark_mode_path},
          {name: "Theming", path: docs_theming_path},
          {name: "Customizing components", path: docs_customizing_components_path}
        ]
      end

      def installation_links
        [
          {name: "Rails - JS Bundler", path: docs_installation_rails_bundler_path},
          {name: "Rails - Importmaps", path: docs_installation_rails_importmaps_path}
        ]
      end

      def components
        [
          {name: "Accordion", path: docs_accordion_path},
          {name: "Alert", path: docs_alert_path},
          {name: "Alert Dialog", path: docs_alert_dialog_path},
          {name: "Aspect Ratio", path: docs_aspect_ratio_path},
          {name: "Avatar", path: docs_avatar_path},
          {name: "Badge", path: docs_badge_path},
          {name: "Breadcrumb", path: docs_breadcrumb_path, badge: "New"},
          {name: "Button", path: docs_button_path},
          {name: "Calendar", path: docs_calendar_path},
          {name: "Card", path: docs_card_path},
          {name: "Carousel", path: docs_carousel_path, badge: "New"},
          # { name: "Chart", path: docs_chart_path, badge: "New" },
          {name: "Checkbox", path: docs_checkbox_path},
          {name: "Checkbox Group", path: docs_checkbox_group_path},
          {name: "Clipboard", path: docs_clipboard_path},
          {name: "Codeblock", path: docs_codeblock_path},
          {name: "Collapsible", path: docs_collapsible_path},
          {name: "Combobox", path: docs_combobox_path, badge: "Updated"},
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
          {name: "Pagination", path: docs_pagination_path, badge: "New"},
          {name: "Popover", path: docs_popover_path},
          {name: "Progress", path: docs_progress_path, badge: "New"},
          {name: "Radio Button", path: docs_radio_button_path, badge: "New"},
          {name: "Select", path: docs_select_path, badge: "New"},
          {name: "Sheet", path: docs_sheet_path},
          {name: "Shortcut Key", path: docs_shortcut_key_path},
          {name: "Skeleton", path: docs_skeleton_path, badge: "New"},
          {name: "Switch", path: docs_switch_path},
          {name: "Table", path: docs_table_path},
          {name: "Tabs", path: docs_tabs_path},
          {name: "Textarea", path: docs_textarea_path},
          {name: "Theme Toggle", path: docs_theme_toggle_path},
          {name: "Tooltip", path: docs_tooltip_path},
          {name: "Typography", path: docs_typography_path}
        ]
      end

      def menu_link(component)
        current_path = component[:path] == request.path
        a(
          href: component[:path],
          class: [
            "group flex w-full items-center rounded-md border border-transparent px-2 py-1 hover:underline",
            (current_path ? "text-foreground font-medium" : "text-muted-foreground")
          ]
        ) do
          span(class: "flex items-center gap-x-1") do
            span { component[:name] }
            Badge(variant: :success, size: :sm, class: "ml-1") { component[:badge] } if component[:badge]
          end
        end
      end

      def main_link(name, path)
        current_path = path == request.path
        a(
          href: path,
          class: [
            "group flex w-full items-center rounded-md border border-transparent px-2 py-1 hover:underline",
            (current_path ? "text-foreground font-medium" : "text-muted-foreground")
          ]
        ) do
          name
        end
      end
    end
  end
end
