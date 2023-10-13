# frozen_string_literal: true

class CardDescription < ApplicationComponent
    def initialize(**attributes)
        @attributes = attributes
    end

    def template(&)
        p(**@attributes, class: tokens("text-sm text-muted-foreground", @attributes[:class]), &)
    end
end