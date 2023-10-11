# frozen_string_literal: true

class AccordionContent < ApplicationComponent
    def template(&)
        div(data: { accordion_target: "content" }, class: 'pb-4 pt-0 hidden', &)
    end
end