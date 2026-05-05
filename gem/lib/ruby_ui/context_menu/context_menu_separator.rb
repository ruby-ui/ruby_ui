# frozen_string_literal: true

module RubyUI
  class ContextMenuSeparator < Base
    def view_template
      div(**attrs)
    end

    private

    def default_attrs
      {
        role: "separator",
        aria_orientation: "horizontal",
        class: "-mx-1 my-1 h-px bg-border"
      }
    end
  end
end
