# frozen_string_literal: true

class SheetTrigger < ApplicationComponent
    def initialize(**attributes)
        @attributes = attributes
    end

    def template(&)
        div(**@attributes, data: { action: "click->sheet#open"}, &)
    end
end