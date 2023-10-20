# frozen_string_literal: true

class TableCaption < ApplicationComponent
    def initialize(**attributes)
        @attributes = attributes
    end

    def template(&)
        caption(**@attributes, class: tokens("mt-4 text-sm text-muted-foreground", @attributes[:class]), &)
    end
end