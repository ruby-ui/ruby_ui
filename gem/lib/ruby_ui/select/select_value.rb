# frozen_string_literal: true

module RubyUI
  # Shows the selected item's text inside SelectTrigger, or placeholder: while
  # nothing is selected. The controller keeps it in sync with SelectInput.
  class SelectValue < Base
    def initialize(placeholder: nil, **)
      @placeholder = placeholder
      super(**)
    end

    def view_template(&block)
      span(**attrs) do
        value = block&.call
        value || @placeholder
      end
    end

    private

    def default_attrs
      {
        data: {
          slot: "select-value",
          ruby_ui__select_target: "value",
          placeholder_text: @placeholder
        },
        class: "flex flex-1 text-left"
      }
    end
  end
end
