# frozen_string_literal: true

module RubyUI
  # RubyUI extra (no shadcn counterpart): an option that selects or clears
  # every item of a multiple: combobox. Hidden while searching.
  class ComboboxToggleAll < Base
    def view_template(&)
      div(**attrs) do
        yield if block_given?
        span(class: "pointer-events-none absolute right-2 hidden size-4 items-center justify-center group-aria-selected/combobox-item:flex", aria: {hidden: "true"}) do
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
    end

    private

    def default_attrs
      {
        role: "option",
        aria: {selected: "false"},
        data: {
          slot: "combobox-item",
          ruby_ui__combobox_target: "toggleAll",
          action: "click->ruby-ui--combobox#select pointermove->ruby-ui--combobox#hover"
        },
        class: ComboboxItem::ITEM
      }
    end
  end
end
