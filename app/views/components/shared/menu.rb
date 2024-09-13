# frozen_string_literal: true

class Shared::Menu < ApplicationComponent
  def view_template
    div(class: "pb-4") do
      # Main routes (Docs, Components, Themes, Github, Discord, Twitter)
      div(class: "md:hidden") do
        main_link("Docs", helpers.docs_introduction_path)
        main_link("Components", helpers.docs_accordion_path)
        main_link("Themes", helpers.theme_path("default"))
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
      {name: "Introduction", path: helpers.docs_introduction_path},
      {name: "Installation", path: helpers.docs_installation_path},
      {name: "Dark mode", path: helpers.docs_dark_mode_path},
      {name: "Theming", path: helpers.docs_theming_path},
      {name: "Customizing components", path: helpers.docs_customizing_components_path}
    ]
  end

  def installation_links
    [
      {name: "Rails - JS Bundler", path: helpers.docs_installation_rails_bundler_path},
      {name: "Rails - Importmaps", path: helpers.docs_installation_rails_importmaps_path}
    ]
  end

  def components
    [
      {name: "Accordion", path: helpers.docs_accordion_path},
      {name: "Alert", path: helpers.docs_alert_path},
      {name: "Alert Dialog", path: helpers.docs_alert_dialog_path},
      {name: "Aspect Ratio", path: helpers.docs_aspect_ratio_path},
      {name: "Avatar", path: helpers.docs_avatar_path},
      {name: "Badge", path: helpers.docs_badge_path},
      {name: "Button", path: helpers.docs_button_path},
      {name: "Card", path: helpers.docs_card_path},
      {name: "Calendar", path: helpers.docs_calendar_path},
      # { name: "Chart", path: helpers.docs_chart_path, badge: "New" },
      {name: "Checkbox", path: helpers.docs_checkbox_path},
      {name: "Clipboard", path: helpers.docs_clipboard_path},
      {name: "Codeblock", path: helpers.docs_codeblock_path},
      {name: "Collapsible", path: helpers.docs_collapsible_path},
      {name: "Combobox", path: helpers.docs_combobox_path},
      {name: "Command", path: helpers.docs_command_path},
      {name: "Context Menu", path: helpers.docs_context_menu_path},
      {name: "Date Picker", path: helpers.docs_date_picker_path},
      {name: "Dialog / Modal", path: helpers.docs_dialog_path},
      {name: "Dropdown Menu", path: helpers.docs_dropdown_menu_path},
      {name: "Form", path: helpers.docs_form_path},
      {name: "Input", path: helpers.docs_input_path},
      {name: "Hover Card", path: helpers.docs_hover_card_path},
      {name: "Link", path: helpers.docs_link_path},
      {name: "Pagination", path: helpers.docs_pagination_path, badge: "New"},
      {name: "Popover", path: helpers.docs_popover_path},
      {name: "Select", path: helpers.docs_select_path, badge: "New"},
      {name: "Sheet", path: helpers.docs_sheet_path},
      {name: "Shortcut Key", path: helpers.docs_shortcut_key_path},
      {name: "Table", path: helpers.docs_table_path},
      {name: "Tabs", path: helpers.docs_tabs_path},
      {name: "Theme Toggle", path: helpers.docs_theme_toggle_path},
      {name: "Tooltip", path: helpers.docs_tooltip_path},
      {name: "Typography", path: helpers.docs_typography_path}
    ]
  end

  def menu_link(component)
    current_path = component[:path] == helpers.request.path
    a(href: component[:path], class: tokens("group flex w-full items-center rounded-md border border-transparent px-2 py-1 hover:underline", -> { current_path } => "text-foreground font-medium", -> { !current_path } => "text-muted-foreground")) do
      span(class: "flex items-center gap-x-1") do
        span { component[:name] }
        Badge(variant: :success, size: :sm, class: "ml-1") { component[:badge] } if component[:badge]
      end
    end
  end

  def main_link(name, path)
    current_path = path == helpers.request.path
    a(href: path, class: tokens("group flex w-full items-center rounded-md border border-transparent px-2 py-1 hover:underline", -> { current_path } => "text-foreground font-medium", -> { !current_path } => "text-muted-foreground")) do
      name
    end
  end
end
