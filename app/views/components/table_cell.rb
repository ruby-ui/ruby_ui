# frozen_string_literal: true

class TableCell < ApplicationComponent
    def initialize(**attributes)
        @attributes = attributes
    end

    def template(&)
        td(**@attributes, class: tokens("p-2 align-middle [&:has([role=checkbox])]:pr-0 [&>[role=checkbox]]:translate-y-[2px]", @attributes[:class]), &)
    end
end