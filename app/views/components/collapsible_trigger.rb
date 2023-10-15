# frozen_string_literal: true

class CollapsibleTrigger < ApplicationComponent
    def template(&)
        div(data: { action: "click->collapsible#toggle" }, class: 'inline-block', &)
    end
end