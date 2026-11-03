# frozen_string_literal: true

module RubyUI
  # The item that opens a submenu: on hover, click, Enter, Space or ArrowRight.
  class DropdownMenuSubTrigger < Base
    def initialize(inset: false, disabled: false, **)
      @inset = inset
      @disabled = disabled
      super(**)
    end

    def view_template(&block)
      div(**mix(sub_attrs, attrs)) do
        yield if block
        chevron_right_icon
      end
    end

    private

    # lucide chevron-right
    def chevron_right_icon
      svg(
        xmlns: "http://www.w3.org/2000/svg",
        viewbox: "0 0 24 24",
        fill: "none",
        stroke: "currentColor",
        stroke_width: "2",
        stroke_linecap: "round",
        stroke_linejoin: "round",
        aria_hidden: "true",
        class: "ml-auto rtl:rotate-180"
      ) { |s| s.path(d: "m9 18 6-6-6-6") }
    end

    # The ids come from the DropdownMenuSub around it, known only while rendering.
    def sub_attrs
      id = context[:ruby_ui_dropdown_menu_sub]
      return {} unless id

      {id: "#{id}-trigger", aria: {controls: "#{id}-content"}}
    end

    def default_attrs
      {
        role: "menuitem",
        tabindex: "-1",
        aria: {
          haspopup: "menu",
          expanded: "false",
          disabled: (@disabled ? "true" : nil)
        },
        data: {
          slot: "dropdown-menu-sub-trigger",
          inset: @inset,
          disabled: @disabled,
          action: "click->ruby-ui--dropdown-menu#toggleSub pointermove->ruby-ui--dropdown-menu#hover pointerleave->ruby-ui--dropdown-menu#leave"
        },
        class: [
          "flex cursor-default items-center gap-2 rounded-sm px-2 py-1.5 text-sm outline-hidden select-none",
          "focus:bg-accent focus:text-accent-foreground not-data-[variant=destructive]:focus:**:text-accent-foreground",
          "data-popup-open:bg-accent data-popup-open:text-accent-foreground",
          "data-disabled:pointer-events-none data-disabled:opacity-50 data-inset:pl-8",
          "[&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4"
        ]
      }
    end
  end
end
