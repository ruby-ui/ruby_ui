# frozen_string_literal: true

class AccordionTrigger < ApplicationComponent
    def template(&)
        button(data: { action: "click->accordion#toggle" }, class: 'w-full flex flex-1 items-center justify-between py-4 text-sm font-medium transition-all hover:underline') do
            span(&)
            icon
        end
    end

    def icon(&block)
        div(data: { accordion_target: "icon" }, class: 'flex items-center justify-center w-6 h-6') do
            if block
                block
            else
                svg(
                    xmlns: "http://www.w3.org/2000/svg",
                    fill: "none",
                    viewbox: "0 0 24 24",
                    stroke_width: "1.5",
                    stroke: "currentColor",
                    class: "w-4 h-4 opacity-50"
                    ) do |s|
                    s.path(
                        stroke_linecap: "round",
                        stroke_linejoin: "round",
                        d: "M19.5 8.25l-7.5 7.5-7.5-7.5"
                    )
                end
            end
        end
    end
end