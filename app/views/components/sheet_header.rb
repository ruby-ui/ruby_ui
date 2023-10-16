# frozen_string_literal: true

class SheetHeader < ApplicationComponent
    def initialize(**attributes)
        @attributes = attributes
    end

    def template(&)
        div(**@attributes, class: tokens("flex flex-col space-y-1.5 text-center sm:text-left", @attributes[:class]), &)
    end
end