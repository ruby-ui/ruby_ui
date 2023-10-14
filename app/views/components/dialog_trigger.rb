# frozen_string_literal: true

class DialogTrigger < ApplicationComponent
    def initialize(**attributes)
        @attributes = attributes
    end

    def template(&)
        div(**@attributes, class: tokens("inline-block", @attributes[:class]), data: { action: "click->dialog#open"}, &)
    end
end