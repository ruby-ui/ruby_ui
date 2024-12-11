# frozen_string_literal: true

module RubyUI
  class ComboboxPopover < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        class: "inset-auto m-0 absolute border bg-background shadow-lg rounded-lg",
        role: "popover",
        autofocus: true,
        popover: true,
        data: {
          ruby_ui__combobox_target: "popover",
          action: %w[
            keydown.down->ruby-ui--combobox#keyDownPressed
            keydown.up->ruby-ui--combobox#keyUpPressed
            keydown.enter->ruby-ui--combobox#keyEnterPressed
            keydown.esc->ruby-ui--combobox#closeDialog:prevent
            resize@window->ruby-ui--combobox#updatePopoverWidth
          ]
        }
      }
    end
  end
end
