# frozen_string_literal: true

class DialogDescription < ApplicationComponent
    def initialize(**attributes)
        @attributes = attributes
    end

    def template(&)
        p(**@attributes, class: tokens("text-sm text-muted-foreground", @attributes[:class]), &)
    end
end