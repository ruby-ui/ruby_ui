# frozen_string_literal: true

module RubyUI
  class ContextMenuSeparator < Base
    def view_template
      div(**attrs)
    end

    private

    def default_attrs
      {
        role: "separator",
        aria_orientation: "horizontal",
        data: {slot: "context-menu-separator"},
        class: "bg-border -mx-1 my-1 h-px"
      }
    end
  end
end
