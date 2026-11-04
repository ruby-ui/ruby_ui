# frozen_string_literal: true

module RubyUI
  class NonCollapsibleSidebar < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        class: "flex h-full w-(--sidebar-width) flex-col bg-sidebar text-sidebar-foreground",
        # Always open: lets SidebarMenuButton tooltips hide, as shadcn does
        # (its provider state stays "expanded").
        data: {slot: "sidebar", state: "expanded"}
      }
    end
  end
end
