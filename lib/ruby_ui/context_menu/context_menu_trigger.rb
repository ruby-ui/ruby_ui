# frozen_string_literal: true

module RubyUI
  class ContextMenuTrigger < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {
          rbui__context_menu_target: "trigger",
          action: "contextmenu->rbui--context-menu#handleContextMenu"
        }
      }
    end
  end
end
