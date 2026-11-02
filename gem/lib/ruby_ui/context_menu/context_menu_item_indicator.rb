# frozen_string_literal: true

module RubyUI
  # The check of a ContextMenuCheckboxItem / ContextMenuRadioItem, shown only
  # while the item is aria-checked="true". Rendered by those items.
  class ContextMenuItemIndicator < Base
    # Full class names, so Tailwind finds them when it scans the source.
    SHOW_WHEN_CHECKED = {
      checkbox: "group-aria-checked/context-menu-checkbox-item:flex",
      radio: "group-aria-checked/context-menu-radio-item:flex"
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
        data: {slot: "context-menu-item-indicator"},
        class: ["pointer-events-none absolute right-2 hidden items-center justify-center", SHOW_WHEN_CHECKED.fetch(@kind)]
      }
    end
  end
end
