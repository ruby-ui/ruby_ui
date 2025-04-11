# frozen_string_literal: true

module RubyUI
  class SidebarGroup < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        class: "relative flex w-full min-w-0 flex-col p-2",
        data: {
          sidebar: "group"
        }
      }
    end
  end
end
