# frozen_string_literal: true

class Table < ApplicationComponent
    def initialize(**attributes)
        @attributes = attributes
    end

    def template(&)
        div(class: "relative w-full overflow-auto") do
            table(**@attributes, class: tokens("w-full caption-bottom text-sm", @attributes[:class]), &)
        end
    end
end