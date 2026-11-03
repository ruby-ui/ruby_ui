# frozen_string_literal: true

module RubyUI
  class DropdownMenuSeparator < Base
    def view_template
      div(**attrs)
    end

    private

    def default_attrs
      {
        role: "separator",
        aria_orientation: "horizontal",
        data: {slot: "dropdown-menu-separator", orientation: "horizontal"},
        class: "bg-border -mx-1 my-1 h-px"
      }
    end
  end
end
