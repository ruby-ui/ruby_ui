# frozen_string_literal: true

module RubyUI
  # The button that opens the list (Base UI's Select.Trigger with role=combobox).
  # size: :default (h-9) or :sm (h-8), as in shadcn's SelectTrigger.
  class SelectTrigger < Base
    SIZES = %i[default sm].freeze

    def initialize(size: :default, **)
      @size = SIZES.include?(size.to_s.to_sym) ? size.to_s.to_sym : :default
      super(**)
    end

    def view_template(&block)
      button(**attrs) do
        block&.call
        icon
      end
    end

    private

    def icon
      svg(
        xmlns: "http://www.w3.org/2000/svg",
        viewbox: "0 0 24 24",
        fill: "none",
        stroke: "currentColor",
        stroke_width: "2",
        stroke_linecap: "round",
        stroke_linejoin: "round",
        aria_hidden: "true",
        class: "pointer-events-none size-4 text-muted-foreground"
      ) { |s| s.path(d: "m6 9 6 6 6-6") }
    end

    def default_attrs
      {
        type: "button",
        role: "combobox",
        # aria-controls is set by the controller while the list is open.
        aria: {haspopup: "listbox", expanded: "false"},
        data: {
          slot: "select-trigger",
          size: @size,
          ruby_ui__select_target: "trigger",
          action: "click->ruby-ui--select#toggle keydown->ruby-ui--select#triggerKeydown"
        },
        class: [
          "flex w-fit items-center justify-between gap-1.5 whitespace-nowrap rounded-md border border-input bg-transparent py-2 pr-2 pl-2.5 text-sm shadow-xs outline-none",
          "transition-[color,box-shadow] data-placeholder:text-muted-foreground",
          "focus-visible:border-ring focus-visible:ring-3 focus-visible:ring-ring/50",
          "aria-invalid:border-destructive aria-invalid:ring-3 aria-invalid:ring-destructive/20",
          "dark:bg-input/30 dark:hover:bg-input/50 dark:aria-invalid:border-destructive/50 dark:aria-invalid:ring-destructive/40",
          "disabled:cursor-not-allowed disabled:opacity-50",
          "aria-disabled:cursor-not-allowed aria-disabled:opacity-50 aria-disabled:pointer-events-none",
          # A bare class, so a caller's h-* replaces it through TailwindMerge.
          (@size == :sm) ? "h-8" : "h-9",
          "*:data-[slot=select-value]:line-clamp-1 *:data-[slot=select-value]:flex *:data-[slot=select-value]:items-center *:data-[slot=select-value]:gap-1.5",
          "[&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4"
        ]
      }
    end
  end
end
