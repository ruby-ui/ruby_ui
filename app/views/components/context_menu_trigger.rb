# frozen_string_literal: true

class ContextMenuTrigger < ApplicationComponent
    def initialize(**attributes)
        @attributes = attributes
    end

    def template(&)
        div(**@attributes, data: { popover_target: 'trigger', action: 'contextmenu->popover#handleContextMenu' }, &)
    end
end