# frozen_string_literal: true

class PopoverTrigger < ApplicationComponent
    def initialize(**attributes)
        @attributes = attributes
    end

    def template(&)
        div(**@attributes, data: { popover_target: 'trigger' }, &)
    end
end