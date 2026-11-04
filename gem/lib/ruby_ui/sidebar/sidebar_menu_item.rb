# frozen_string_literal: true

module RubyUI
  class SidebarMenuItem < Base
    def view_template(&)
      li(**attrs, &)
    end

    private

    def default_attrs
      {
        class: "group/menu-item relative",
        data: {
          slot: "sidebar-menu-item",
          sidebar: "menu-item"
        }
      }
    end
  end
end
