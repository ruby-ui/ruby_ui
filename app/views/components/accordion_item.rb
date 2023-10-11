# frozen_string_literal: true

class AccordionItem < ApplicationComponent
    def initialize(open: false)
        @open = open
    end

    def template(&)
        div(data: { controller: "accordion", accordion_open_value: @open }, class: 'border-b', &)
    end
end
