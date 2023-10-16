# frozen_string_literal: true

class SheetMiddle < ApplicationComponent
    def initialize(**attributes)
        @attributes = attributes
    end

    def template(&)
        div(**@attributes, class: tokens("py-4", @attributes[:class]), &)
    end
end