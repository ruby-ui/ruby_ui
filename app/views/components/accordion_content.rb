# frozen_string_literal: true

class AccordionContent < ApplicationComponent
    def template(&)
        div(data: { accordion_target: "content" }, class: 'overflow-y-hidden') do
            div(class: 'pb-4 pt-0', &)
        end
    end
end