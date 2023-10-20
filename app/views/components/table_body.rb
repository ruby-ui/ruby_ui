# frozen_string_literal: true

class TableBody < ApplicationComponent
    def initialize(**attributes)
        @attributes = attributes
    end

    def template(&)
        tbody(**@attributes, class: tokens("[&_tr:last-child]:border-0", @attributes[:class]), &)
    end
end