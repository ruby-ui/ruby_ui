# frozen_string_literal: true

class CardFooter < ApplicationComponent
    def initialize(**attributes)
        @attributes = attributes
    end

    def template(&)
        div(**@attributes, class: tokens("items-center p-6 pt-0", @attributes[:class]), &)
    end
end