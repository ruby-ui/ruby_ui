# frozen_string_literal: true

module RubyUI
  class DropdownMenuItem < Base
    def initialize(href: "#", **attrs)
      @href = href
      super(**attrs)
    end

    def view_template(&)
      a(**attrs, &)
    end

    private

    def default_attrs
      {
        href: @href,
        role: "menuitem",
        class: "relative flex cursor-pointer select-none items-center rounded-sm px-2 py-1.5 text-sm outline-none transition-colors hover:bg-accent hover:text-accent-foreground focus:bg-accent focus:text-accent-foreground aria-selected:bg-accent aria-selected:text-accent-foreground data-[disabled]:pointer-events-none data-[disabled]:opacity-50",
        data_action: "click->ruby-ui--dropdown-menu#close",
        data_ruby_ui__dropdown_menu_target: "menuItem",
        tabindex: "-1",
        data_orientation: "vertical"
      }
    end
  end
end
