# frozen_string_literal: true

module RubyUI
  # An option. Focus moves onto it (roving tabindex), as in Base UI's
  # Select.Item; the check on the right marks the selected one.
  class SelectItem < Base
    def initialize(value: nil, disabled: false, **)
      @value = value
      @disabled = disabled
      super(**)
    end

    def view_template(&)
      div(**attrs) do
        span(class: "flex flex-1 shrink-0 gap-2 whitespace-nowrap", &)
        indicator
      end
    end

    private

    def indicator
      span(class: "pointer-events-none invisible absolute right-2 size-4 items-center justify-center group-aria-selected/select-item:visible", aria: {hidden: "true"}) do
        svg(
          xmlns: "http://www.w3.org/2000/svg",
          viewbox: "0 0 24 24",
          fill: "none",
          stroke: "currentColor",
          stroke_width: "2",
          stroke_linecap: "round",
          stroke_linejoin: "round",
          aria_hidden: "true",
          class: "pointer-events-none size-4"
        ) { |s| s.path(d: "M20 6 9 17l-5-5") }
      end
    end

    def default_attrs
      {
        role: "option",
        tabindex: "-1",
        aria: {selected: "false", disabled: (@disabled ? "true" : nil)},
        data: {
          slot: "select-item",
          value: @value,
          disabled: (@disabled ? "" : nil),
          ruby_ui__select_target: "item",
          action: "click->ruby-ui--select#select pointermove->ruby-ui--select#hover"
        },
        class: [
          "group/select-item relative flex w-full cursor-default items-center gap-2 rounded-sm py-1.5 pr-8 pl-2 text-sm outline-hidden select-none",
          "focus:bg-accent focus:text-accent-foreground not-data-[variant=destructive]:focus:**:text-accent-foreground",
          "data-disabled:pointer-events-none data-disabled:opacity-50",
          "aria-disabled:pointer-events-none aria-disabled:opacity-50",
          "[&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4",
          "*:[span]:last:flex *:[span]:last:items-center *:[span]:last:gap-2"
        ]
      }
    end
  end
end
