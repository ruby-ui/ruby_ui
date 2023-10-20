# frozen_string_literal: true

class TableRow < ApplicationComponent
    def initialize(**attributes)
        @attributes = attributes
    end

    def template(&)
        tr(**@attributes, class: tokens("border-b transition-colors hover:bg-muted/50 data-[state=selected]:bg-muted", @attributes[:class]), &)
    end
end