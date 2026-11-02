# frozen_string_literal: true

module RubyUI
  # The root. Placement lives on ContextMenuContent (side:, align:, offsets).
  class ContextMenu < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {
          slot: "context-menu",
          controller: "ruby-ui--context-menu"
        }
      }
    end
  end
end
