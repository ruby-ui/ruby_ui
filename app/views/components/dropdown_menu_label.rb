# frozen_string_literal: true

class DropdownMenuLabel < ApplicationComponent
    def initialize(**attributes)
        @attributes = attributes
    end

    def template(&)
        h3(**@attributes, class: tokens("px-2 py-1.5 text-sm font-semibold", @attributes[:class]), &)
    end
end