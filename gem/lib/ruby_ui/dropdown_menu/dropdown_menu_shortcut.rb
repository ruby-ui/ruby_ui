# frozen_string_literal: true

module RubyUI
  # Shows an item's key combination. It only displays the keys: binding them is up to you.
  class DropdownMenuShortcut < Base
    def view_template(&)
      span(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "dropdown-menu-shortcut"},
        class: "ml-auto text-xs tracking-widest text-muted-foreground group-focus/dropdown-menu-item:text-accent-foreground"
      }
    end
  end
end
