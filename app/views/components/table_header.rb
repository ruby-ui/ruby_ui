# frozen_string_literal: true

class TableHeader < ApplicationComponent
    def initialize(**attributes)
        @attributes = attributes
    end

    def template(&)
        thead(**@attributes, class: tokens("[&_tr]:border-b", @attributes[:class]), &)
    end
end