# frozen_string_literal: true

module RubyUI
  class SidebarMenuSub < Base
    def view_template(&)
      ul(**attrs, &)
    end

    private

    def default_attrs
      {
        class: [
          "mx-3.5 flex min-w-0 translate-x-px flex-col gap-1 border-l",
          "border-sidebar-border px-2.5 py-0.5",
          "group-data-[collapsible=icon]:hidden"
        ],
        data: {
          sidebar: "menu-sub"
        }
      }
    end
  end
end
