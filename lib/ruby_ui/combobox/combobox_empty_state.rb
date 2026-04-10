# frozen_string_literal: true

module RubyUI
  class ComboboxEmptyState
    include ComponentBase

    private

    def default_attrs
      {
        role: "presentation",
        class: "hidden py-6 text-center text-sm",
        data: {
          ruby_ui__combobox_target: "emptyState"
        }
      }
    end
  end
end
