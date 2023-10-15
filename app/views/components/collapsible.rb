# frozen_string_literal: true

class Collapsible < ApplicationComponent
    def initialize(open: false, **attributes)
      @attributes = attributes
      @open = open
    end

    def template(&)
        div(**@attributes, data: { controller: 'collapsible', collapsible_open_value: @open }, &)
    end
end
