# frozen_string_literal: true

module RubyUI
  # The check of a DropdownMenuCheckboxItem / DropdownMenuRadioItem, shown only
  # while the item is aria-checked="true". Rendered by those items.
  class DropdownMenuItemIndicator < Base
    # Full class names, so Tailwind finds them when it scans the source.
    SHOW_WHEN_CHECKED = {
      checkbox: "group-aria-checked/dropdown-menu-checkbox-item:flex",
      radio: "group-aria-checked/dropdown-menu-radio-item:flex"
    }.freeze
    SLOTS = {
      checkbox: "dropdown-menu-checkbox-item-indicator",
      radio: "dropdown-menu-radio-item-indicator"
    }.freeze

    def initialize(kind:, **)
      @kind = kind
      super(**)
    end

    def view_template
      span(**attrs) do
        svg(
          xmlns: "http://www.w3.org/2000/svg",
          viewbox: "0 0 24 24",
          fill: "none",
          stroke: "currentColor",
          stroke_width: "2",
          stroke_linecap: "round",
          stroke_linejoin: "round",
          aria_hidden: "true"
        ) { |s| s.path(d: "M20 6 9 17l-5-5") }
      end
    end

    private

    def default_attrs
      {
        aria: {hidden: "true"},
        data: {slot: SLOTS.fetch(@kind)},
        class: ["pointer-events-none absolute right-2 hidden items-center justify-center", SHOW_WHEN_CHECKED.fetch(@kind)]
      }
    end
  end
end
