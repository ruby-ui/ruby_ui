# frozen_string_literal: true

module RubyUI
  class SidebarTrigger
    include ComponentBase

    private

    def default_attrs
      {
        class: "h-7 w-7 [&_svg]:pointer-events-none [&_svg]:size-4 [&_svg]:shrink-0",
        data: {
          sidebar: "trigger",
          action: "click->ruby-ui--sidebar#toggle"
        }
      }
    end
  end
end
