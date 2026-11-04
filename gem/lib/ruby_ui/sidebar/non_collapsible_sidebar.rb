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
        data: {slot: "sidebar"}
      }
    end
  end
end
