# frozen_string_literal: true

module RubyUI
  class DropdownMenuLabel
    include ComponentBase

    private

    def default_attrs
      {
        class: "px-2 py-1.5 text-sm font-semibold"
      }
    end
  end
end
