# frozen_string_literal: true

class Shared::Menu < ApplicationComponent
    def template
        div(class: 'pb-4') do
            h4(class: 'mb-1 rounded-md px-2 py-1 text-sm font-semibold flex items-center gap-x-2') do
                plain "Components"
                render Badge.new(variant: :neutral, size: :sm) { components.count.to_s }
            end
            div(class: 'grid grid-flow-row auto-rows-max text-sm') do
                components.each do |component|
                    component_link(component)
                end
            end
            h4(class: 'mb-1 mt-6 rounded-md px-2 py-1 text-sm font-semibold flex items-center gap-x-2') do
                plain "Coming Soon"
                render Badge.new(variant: :neutral, size: :sm) { components_coming_soon.count.to_s }
                svg(
                    xmlns: "http://www.w3.org/2000/svg",
                    viewbox: "0 0 24 24",
                    fill: "currentColor",
                    class: "w-4 h-4 text-amber-400"
                ) do |s|
                    s.path(
                        fill_rule: "evenodd",
                        d:
                        "M9 4.5a.75.75 0 01.721.544l.813 2.846a3.75 3.75 0 002.576 2.576l2.846.813a.75.75 0 010 1.442l-2.846.813a3.75 3.75 0 00-2.576 2.576l-.813 2.846a.75.75 0 01-1.442 0l-.813-2.846a3.75 3.75 0 00-2.576-2.576l-2.846-.813a.75.75 0 010-1.442l2.846-.813A3.75 3.75 0 007.466 7.89l.813-2.846A.75.75 0 019 4.5zM18 1.5a.75.75 0 01.728.568l.258 1.036c.236.94.97 1.674 1.91 1.91l1.036.258a.75.75 0 010 1.456l-1.036.258c-.94.236-1.674.97-1.91 1.91l-.258 1.036a.75.75 0 01-1.456 0l-.258-1.036a2.625 2.625 0 00-1.91-1.91l-1.036-.258a.75.75 0 010-1.456l1.036-.258a2.625 2.625 0 001.91-1.91l.258-1.036A.75.75 0 0118 1.5zM16.5 15a.75.75 0 01.712.513l.394 1.183c.15.447.5.799.948.948l1.183.395a.75.75 0 010 1.422l-1.183.395c-.447.15-.799.5-.948.948l-.395 1.183a.75.75 0 01-1.422 0l-.395-1.183a1.5 1.5 0 00-.948-.948l-1.183-.395a.75.75 0 010-1.422l1.183-.395c.447-.15.799-.5.948-.948l.395-1.183A.75.75 0 0116.5 15z",
                        clip_rule: "evenodd"
                    )
                end
            end
            div(class: 'grid grid-flow-row auto-rows-max text-sm') do
                components_coming_soon.each do |component|
                    component_link(component)
                end
            end
        end
    end

    def components
        [
            { name: "Accordion", path: helpers.docs_accordion_path, premium: false },
            { name: "Alert", path: helpers.docs_alert_path, premium: false },
            { name: "Alert Dialog", path: helpers.docs_alert_dialog_path, premium: false },
            { name: "Aspect Ratio", path: helpers.docs_aspect_ratio_path, premium: false },
            { name: "Avatar", path: helpers.docs_avatar_path, premium: false },
            { name: "Badge", path: helpers.docs_badge_path, premium: false },
            { name: "Button", path: helpers.docs_button_path, premium: false },
            { name: "Card", path: helpers.docs_card_path, premium: false },
            { name: "Calendar", path: helpers.docs_calendar_path, premium: true },
            { name: "Checkbox", path: helpers.docs_checkbox_path, premium: false },
            { name: "Codeblock", path: helpers.docs_codeblock_path, premium: false },
            { name: "Collapsible", path: helpers.docs_collapsible_path, premium: false },
            { name: "Command", path: helpers.docs_command_path, premium: true },
            { name: "Context Menu", path: helpers.docs_context_menu_path, premium: false },
            { name: "Date Picker", path: helpers.docs_date_picker_path, premium: true },
            { name: "Dialog / Modal", path: helpers.docs_dialog_path, premium: false },
            { name: "Dropdown Menu", path: helpers.docs_dropdown_menu_path, premium: false },
            { name: "Input", path: helpers.docs_input_path, premium: false },
            { name: "Hover Card", path: helpers.docs_hover_card_path, premium: false },
            { name: "Link", path: helpers.docs_link_path, premium: false },
            { name: "Popover", path: helpers.docs_popover_path, premium: false },
            { name: "Sheet", path: helpers.docs_sheet_path, premium: true },
            { name: "Shortcut Key", path: helpers.docs_shortcut_key_path, premium: true },
            { name: "Tabs", path: helpers.docs_tabs_path, premium: false },
            { name: "Theme Toggle", path: helpers.docs_theme_toggle_path, premium: false },
            { name: "Tooltip", path: helpers.docs_tooltip_path, premium: false },
            { name: "Typography", path: helpers.docs_typography_path, premium: false },
        ]
    end

    def components_coming_soon
        [
            { name: "Autosave", path: '#', premium: false },
            { name: "Carousel", path: '#', premium: true },
            { name: "Clipboard", path: '#', premium: false },
            { name: "Color Picker", path: '#', premium: true },
            { name: "Combobox", path: '#', premium: true },
            { name: "Data Table", path: '#', premium: true },
            { name: "Form", path: '#', premium: false },
            { name: "Menu Bar", path: '#', premium: true },
            { name: "Multi Select", path: '#', premium: true },
            { name: "Navigation Menu", path: '#', premium: true },
            { name: "Pagination", path: '#', premium: false },
            { name: "Progress", path: '#', premium: false },
            { name: "Radio Group", path: '#', premium: false },
            { name: "Read more", path: '#', premium: false },
            { name: "Rich text editor", path: '#', premium: true },
            { name: "Scroll Area", path: '#', premium: false },
            { name: "Select", path: '#', premium: false },
            { name: "Separator", path: '#', premium: false },
            { name: "Skeleton Loader", path: '#', premium: false },
            { name: "Slider", path: '#', premium: false },
            { name: "Switch", path: '#', premium: false },
            { name: "Table", path: '#', premium: false },
            { name: "Textarea (Autogrow)", path: '#', premium: false },
            { name: "Toast (Swipe to dismiss)", path: '#', premium: true },
            { name: "Toggle", path: '#', premium: false },
            { name: "Turbo Dialog / Modal", path: '#', premium: true },
            { name: "Video Player", path: '#', premium: true },
        ]
    end

    def component_link(component)
        current_path = component[:path] == helpers.request.path
        return a(href: component[:path], class: tokens('group flex w-full items-center rounded-md border border-transparent px-2 py-1 hover:underline', -> { current_path } => "text-foreground font-medium", -> { !current_path } => "text-muted-foreground")) do
            span(class: 'flex items-center gap-x-1') do
                span { component[:name] }
                premium_status(component) if component[:premium]
            end
        end
    end

    def premium_status(component)
        if component[:premium]
            svg(
                xmlns: "http://www.w3.org/2000/svg",
                viewbox: "0 0 24 24",
                fill: "currentColor",
                class: "w-3 h-3 text-violet-300 ml-2"
            ) do |s|
                s.path(
                    fill_rule: "evenodd",
                    d:
                    "M12 1.5a5.25 5.25 0 00-5.25 5.25v3a3 3 0 00-3 3v6.75a3 3 0 003 3h10.5a3 3 0 003-3v-6.75a3 3 0 00-3-3v-3c0-2.9-2.35-5.25-5.25-5.25zm3.75 8.25v-3a3.75 3.75 0 10-7.5 0v3h7.5z",
                    clip_rule: "evenodd"
                )
            end
        end
    end
end
