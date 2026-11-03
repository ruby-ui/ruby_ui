# frozen_string_literal: true

module RubyUI
  # Wraps the element that opens the menu (usually a Button). The wrapper is
  # display: contents; the controller puts aria-haspopup, aria-expanded,
  # aria-controls and data-slot="dropdown-menu-trigger" on the button inside,
  # the element shadcn's trigger renders.
  class DropdownMenuTrigger < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {
          ruby_ui__dropdown_menu_target: "trigger",
          action: "click->ruby-ui--dropdown-menu#toggle"
        },
        class: "contents"
      }
    end
  end
end
