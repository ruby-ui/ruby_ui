# frozen_string_literal: true

module RubyUI
  class ContextMenuTrigger
    include ComponentBase

    private

    def default_attrs
      {
        data: {
          ruby_ui__context_menu_target: "trigger",
          action: "contextmenu->ruby-ui--context-menu#handleContextMenu"
        }
      }
    end
  end
end
