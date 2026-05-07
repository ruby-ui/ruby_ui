# frozen_string_literal: true

module RubyUI
  class SidebarMenuSubItem < Base
    def view_template(&)
      li(**attrs, &)
    end
  end
end
