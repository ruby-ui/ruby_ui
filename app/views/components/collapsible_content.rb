# frozen_string_literal: true

class CollapsibleContent < ApplicationComponent
    def template(&)
        div(data: { collapsible_target: "content" }, class: 'overflow-y-hidden') do
            div(class: 'pb-4 pt-0', &)
        end
    end
end