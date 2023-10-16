# frozen_string_literal: true

class Calendar < ApplicationComponent
    def initialize(selected_date: nil, **attributes)
        @selected_date = selected_date
        @attributes = attributes
    end

    def template
        div(**@attributes, class: tokens("rdp p-3", @attributes[:class]), data_controller: "calendar", data_calendar_selected_date_value: @selected_date&.to_s) do
            div(class: "space-y-4 rdp-caption_start rdp-caption_end") do
                div(class: "flex justify-center pt-1 relative items-center") do
                    div(
                        class: "text-sm font-medium",
                        aria_live: "polite",
                        role: "presentation",
                        data_calendar_target: "title"
                    ) { "Month Year" }
                    div(class: "space-x-1 flex items-center") do
                        prev_month_button
                        next_month_button
                    end
                end
                table(data_calendar_target: "calendar")
            end
        end
    end

    private

    def prev_month_button
        button(
            name: "previous-month",
            aria_label: "Go to previous month",
            class:
                "rdp-button_reset rdp-button inline-flex items-center justify-center rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 border border-input hover:bg-accent hover:text-accent-foreground h-7 w-7 bg-transparent p-0 opacity-50 hover:opacity-100 absolute left-1",
            type: "button",
            data_action: "click->calendar#prevMonth"
        ) do
            svg(
                width: "15",
                height: "15",
                viewbox: "0 0 15 15",
                fill: "none",
                xmlns: "http://www.w3.org/2000/svg",
                class: "h-4 w-4"
            ) do |s|
                s.path(
                    d:
                        "M8.84182 3.13514C9.04327 3.32401 9.05348 3.64042 8.86462 3.84188L5.43521 7.49991L8.86462 11.1579C9.05348 11.3594 9.04327 11.6758 8.84182 11.8647C8.64036 12.0535 8.32394 12.0433 8.13508 11.8419L4.38508 7.84188C4.20477 7.64955 4.20477 7.35027 4.38508 7.15794L8.13508 3.15794C8.32394 2.95648 8.64036 2.94628 8.84182 3.13514Z",
                    fill: "currentColor",
                    fill_rule: "evenodd",
                    clip_rule: "evenodd"
                )
            end
        end
    end

    def next_month_button
        button(
            name: "next-month",
            aria_label: "Go to next month",
            class:
                "rdp-button_reset rdp-button inline-flex items-center justify-center rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 border border-input hover:bg-accent hover:text-accent-foreground h-7 w-7 bg-transparent p-0 opacity-50 hover:opacity-100 absolute right-1",
            type: "button",
            data_action: "click->calendar#nextMonth"
        ) do
            svg(
                width: "15",
                height: "15",
                viewbox: "0 0 15 15",
                fill: "none",
                xmlns: "http://www.w3.org/2000/svg",
                class: "h-4 w-4"
            ) do |s|
                s.path(
                    d:
                        "M6.1584 3.13508C6.35985 2.94621 6.67627 2.95642 6.86514 3.15788L10.6151 7.15788C10.7954 7.3502 10.7954 7.64949 10.6151 7.84182L6.86514 11.8418C6.67627 12.0433 6.35985 12.0535 6.1584 11.8646C5.95694 11.6757 5.94673 11.3593 6.1356 11.1579L9.565 7.49985L6.1356 3.84182C5.94673 3.64036 5.95694 3.32394 6.1584 3.13508Z",
                    fill: "currentColor",
                    fill_rule: "evenodd",
                    clip_rule: "evenodd"
                )
            end
        end
    end
end