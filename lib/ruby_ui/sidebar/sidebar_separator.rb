# frozen_string_literal: true

module RubyUI
  class SidebarSeparator < Base
    def view_template(&)
      Separator(**attrs, &)
    end

    private

    def default_attrs
      {
        class: "mx-2 w-auto bg-sidebar-border",
        data: {
          sidebar: "separator"
        }
      }
    end
  end
end
