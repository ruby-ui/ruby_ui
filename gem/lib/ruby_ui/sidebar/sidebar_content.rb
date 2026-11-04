# frozen_string_literal: true

module RubyUI
  class SidebarContent < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        class: "flex min-h-0 flex-1 flex-col gap-2 overflow-auto [scrollbar-width:none] group-data-[collapsible=icon]:overflow-hidden [&::-webkit-scrollbar]:hidden",
        data: {
          slot: "sidebar-content",
          sidebar: "content"
        }
      }
    end
  end
end
