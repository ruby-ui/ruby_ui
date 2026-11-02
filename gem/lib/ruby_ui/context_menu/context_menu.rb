# frozen_string_literal: true

module RubyUI
  # The root. Placement lives on ContextMenuContent (side:, align:, offsets).
  class ContextMenu < Base
    def initialize(**attrs)
      if attrs.key?(:options)
        raise ArgumentError, "ContextMenu(options:) was removed; use ContextMenuContent(side:, align:, side_offset:, align_offset:)"
      end
      super
    end

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
