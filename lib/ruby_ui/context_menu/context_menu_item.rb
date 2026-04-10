# frozen_string_literal: true

module RubyUI
  class ContextMenuItem
    include ComponentBase

    def initialize(href: "#", checked: false, shortcut: nil, disabled: false, **attrs)
      @href = href
      @checked = checked
      @shortcut = shortcut
      @disabled = disabled
      super(**attrs)
    end

    def checked?
      @checked
    end

    attr_reader :shortcut

    private

    def default_attrs
      {
        href: @href,
        role: "menuitem",
        class: "relative flex cursor-pointer select-none items-center rounded-sm px-2 py-1.5 text-sm outline-none hover:bg-accent hover:text-accent-foreground focus:bg-accent focus:text-accent-foreground aria-selected:bg-accent aria-selected:text-accent-foreground data-[disabled]:pointer-events-none data-[disabled]:opacity-50 pl-8",
        tabindex: "-1",
        data_orientation: "vertical",
        data_action: "click->ruby-ui--context-menu#close",
        data_ruby_ui__context_menu_target: "menuItem",
        data_disabled: @disabled,
        disabled: @disabled
      }
    end
  end
end
