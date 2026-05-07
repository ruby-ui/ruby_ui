# frozen_string_literal: true

module RubyUI
  class SidebarGroupContent < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        class: "w-full text-sm",
        data: {
          sidebar: "group-content"
        }
      }
    end
  end
end
