# frozen_string_literal: true

module RubyUI
  class SidebarInput < Base
    def view_template(&)
      Input(**attrs, &)
    end

    private

    def default_attrs
      {
        class: "h-8 w-full bg-background shadow-none focus-visible:ring-2 focus-visible:ring-sidebar-ring",
        data: {
          sidebar: "input"
        }
      }
    end
  end
end
