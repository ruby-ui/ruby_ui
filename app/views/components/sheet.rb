# frozen_string_literal: true

class Sheet < ApplicationComponent
    def initialize(**attributes)
        @attributes = attributes
    end

    def template(&)
        div(**@attributes, data: { controller: "sheet"}, &)
    end
end