# frozen_string_literal: true

class CommandDialogTrigger < ApplicationComponent
    def initialize(**attributes)
        @attributes = attributes
    end

    def template(&)
        div(**@attributes, data: { action: "click->dialog#open"}, &)
    end
end