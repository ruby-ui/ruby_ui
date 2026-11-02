# frozen_string_literal: true

module RubyUI
  # The area that opens the menu on right click (or the ContextMenu key).
  class ContextMenuTrigger < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {
          slot: "context-menu-trigger",
          ruby_ui__context_menu_target: "trigger",
          action: "contextmenu->ruby-ui--context-menu#handleContextMenu"
        },
        class: "select-none"
      }
    end
  end
end
