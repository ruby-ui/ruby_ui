# frozen_string_literal: true

class CommandList < ApplicationComponent
    def initialize(**attributes)
        @attributes = attributes
    end

    def template(&)
        div(**@attributes, class: tokens("divide-y divide-border", @attributes[:class]), &)
    end
end