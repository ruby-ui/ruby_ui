# frozen_string_literal: true

module RubyUI
  class ComboboxList < Base
    include ComboboxContext

    def view_template(&)
      div(**with_combobox_defaults(id: combobox[:list_id], aria: {multiselectable: (combobox[:multiple] ? "true" : nil)}), &)
    end

    private

    def default_attrs
      {
        role: "listbox",
        data: {
          slot: "combobox-list",
          ruby_ui__combobox_target: "list",
          # Clicking an option must not take focus away from the input.
          action: "mousedown->ruby-ui--combobox#keepFocus"
        },
        class: [
          "max-h-[min(calc(--spacing(72)---spacing(9)),calc(var(--available-height,100vh)---spacing(9)))]",
          "scroll-py-1 overflow-y-auto overscroll-contain p-1 data-empty:p-0",
          "[scrollbar-width:none] [&::-webkit-scrollbar]:hidden"
        ]
      }
    end
  end
end
