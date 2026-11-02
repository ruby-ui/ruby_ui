# frozen_string_literal: true

module RubyUI
  # One selected item inside ComboboxChips. Rendered by the controller from
  # ComboboxChips' template; its text goes in the [data-text] span.
  class ComboboxChip < Base
    def initialize(show_remove: true, **)
      @show_remove = show_remove
      super(**)
    end

    def view_template(&)
      div(**attrs) do
        span(data: {text: ""}, &)
        remove_button if @show_remove
      end
    end

    private

    def remove_button
      render Button.new(
        variant: :ghost, size: :xs, icon: true, tabindex: -1,
        class: "-ml-1 opacity-50 hover:opacity-100",
        aria: {label: "Remove"},
        data: {slot!: "combobox-chip-remove", action: "click->ruby-ui--combobox#removeChip"}
      ) do
        svg(
          xmlns: "http://www.w3.org/2000/svg",
          viewbox: "0 0 24 24",
          fill: "none",
          stroke: "currentColor",
          stroke_width: "2",
          stroke_linecap: "round",
          stroke_linejoin: "round",
          aria_hidden: "true",
          class: "pointer-events-none"
        ) do |s|
          s.path(d: "M18 6 6 18")
          s.path(d: "m6 6 12 12")
        end
      end
    end

    def default_attrs
      {
        data: {slot: "combobox-chip"},
        class: [
          "flex h-[calc(--spacing(5.5))] w-fit items-center justify-center gap-1 rounded-sm bg-muted px-1.5",
          "text-xs font-medium whitespace-nowrap text-foreground has-data-[slot=combobox-chip-remove]:pr-0",
          "has-disabled:pointer-events-none has-disabled:cursor-not-allowed has-disabled:opacity-50"
        ]
      }
    end
  end
end
