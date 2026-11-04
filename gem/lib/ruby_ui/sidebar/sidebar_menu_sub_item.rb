# frozen_string_literal: true

module RubyUI
  class SidebarMenuSubItem < Base
    def view_template(&)
      li(**attrs, &)
    end

    private

    def default_attrs
      {
        class: "group/menu-sub-item relative",
        data: {
          slot: "sidebar-menu-sub-item",
          sidebar: "menu-sub-item"
        }
      }
    end
  end
end
