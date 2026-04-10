# frozen_string_literal: true

module RubyUI
  class DropdownMenuSeparator
    include ComponentBase

    private

    def default_attrs
      {
        role: "separator",
        aria_orientation: "horizontal",
        class: "-mx-1 my-1 h-px bg-muted"
      }
    end
  end
end
