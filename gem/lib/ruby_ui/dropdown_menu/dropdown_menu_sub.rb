# frozen_string_literal: true

require "securerandom"

module RubyUI
  # A submenu: one DropdownMenuSubTrigger and its DropdownMenuSubContent,
  # tied together by ids (aria-controls / aria-labelledby).
  class DropdownMenuSub < Base
    def initialize(id: nil, **)
      @id = id || "dropdown-menu-sub-#{SecureRandom.hex(4)}"
      super(**)
    end

    def view_template(&)
      previous = context[:ruby_ui_dropdown_menu_sub]
      context[:ruby_ui_dropdown_menu_sub] = @id
      div(**attrs, &)
    ensure
      context[:ruby_ui_dropdown_menu_sub] = previous
    end

    private

    def default_attrs
      {data: {slot: "dropdown-menu-sub"}}
    end
  end
end
