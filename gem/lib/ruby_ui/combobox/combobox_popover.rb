# frozen_string_literal: true

module RubyUI
  class ComboboxPopover < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        class: [
          "inset-auto m-0 absolute border bg-background shadow-lg rounded-lg",
          "data-[state=open]:animate-in data-[state=open]:fade-in-0 data-[state=open]:zoom-in-95",
          "data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=closed]:zoom-out-95",
          "data-[state=closed]:fill-mode-forwards duration-100",
          "data-[side=bottom]:slide-in-from-top-2 data-[side=left]:slide-in-from-right-2",
          "data-[side=right]:slide-in-from-left-2 data-[side=top]:slide-in-from-bottom-2"
        ],
        autofocus: true,
        popover: "manual",
        data: {
          ruby_ui__combobox_target: "popover",
          action: %w[
            toggle->ruby-ui--combobox#handlePopoverToggle
            keydown.down->ruby-ui--combobox#keyDownPressed
            keydown.up->ruby-ui--combobox#keyUpPressed
            keydown.enter->ruby-ui--combobox#keyEnterPressed
            resize@window->ruby-ui--combobox#updatePopoverWidth
          ]
        }
      }
    end
  end
end
