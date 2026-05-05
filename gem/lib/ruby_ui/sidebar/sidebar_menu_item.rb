# frozen_string_literal: true

module RubyUI
  class SidebarMenuItem < Base
    def view_template(&)
      ul(**attrs, &)
    end

    private

    def default_attrs
      {
        class: "group/menu-item relative",
        data: {
          sidebar: "menu-item"
        }
      }
    end
  end
end
