# frozen_string_literal: true

module RubyUI
  class DropdownMenuOverlay < Base
    def view_template
      div(**attrs)
    end

    private

    def default_attrs
      {
        data: {
          ruby_ui__dropdown_menu_target: "overlay",
          action: "click->ruby-ui--dropdown-menu#onClickOutside"
        },
        class: "absolute fixed inset-0 z-40 bg-black opacity-20 hidden"
      }
    end
  end
end
