# frozen_string_literal: true

class Shared::Menu < ApplicationComponent
    def template
        div(class: 'pb-4') do
            h4(class: 'mb-1 rounded-md px-2 py-1 text-sm font-semibold') { "Components" }
            div(class: 'grid grid-flow-row auto-rows-max text-sm') do
                components.each do |component|
                    component_link(component)
                end
            end
        end
    end

    def components
        [
            { name: "Accordion", path: helpers.docs_accordion_path },
            { name: "Alert", path: helpers.docs_alert_path },
            { name: "Alert Dialog", path: helpers.docs_alert_dialog_path },
            { name: "Aspect Ratio", path: helpers.docs_aspect_ratio_path },
            { name: "Avatar", path: helpers.docs_avatar_path },
            { name: "Badge", path: helpers.docs_badge_path },
            { name: "Button", path: helpers.docs_button_path },
            { name: "Card", path: helpers.docs_card_path },
            { name: "Calendar", path: helpers.docs_calendar_path },
            { name: "Checkbox", path: helpers.docs_checkbox_path },
            { name: "Collapsible", path: helpers.docs_collapsible_path },
            { name: "Dialog", path: helpers.docs_dialog_path },
            { name: "Input", path: helpers.docs_input_path },
            { name: "Link", path: helpers.docs_link_path },
            { name: "Popover", path: helpers.docs_popover_path },
            { name: "Sheet", path: helpers.docs_sheet_path },
            { name: "Tabs", path: helpers.docs_tabs_path },
            { name: "Theme Toggle", path: helpers.docs_theme_toggle_path },
            { name: "Typography", path: helpers.docs_typography_path },
        ]
    end

    def component_link(component)
        current_path = component[:path] == helpers.request.path
        return a(href: component[:path], class: tokens('group flex w-full items-center rounded-md border border-transparent px-2 py-1 hover:underline', -> { current_path } => "text-foreground font-medium", -> { !current_path } => "text-muted-foreground")) { component[:name] }
    end
end
