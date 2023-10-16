# frozen_string_literal: true

class SheetTitle < ApplicationComponent
    def initialize(**attributes)
        @attributes = attributes
    end

    def template(&)
        h3(**@attributes, class: tokens("text-lg font-semibold leading-none tracking-tight", @attributes[:class]), &)
    end
end