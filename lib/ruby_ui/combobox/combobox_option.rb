# frozen_string_literal: true

module RubyUI
  class ComboboxOption < Base
    def initialize(value:, selected: false, **)
      @value = value
      @selected = selected
      super(**)
    end

    def view_template(&)
      div(**attrs) do
        span(class: "invisible group-aria-selected:visible") { check_icon }
        span(&)
      end
    end

    private

    def check_icon
      svg(xmlns: "http://www.w3.org/2000/svg", viewbox: "0 0 24 24", fill: "none", stroke: "currentColor", class: "mr-2 h-4 w-4", stroke_width: "2", stroke_linecap: "round", stroke_linejoin: "round") do |s|
        s.path(
          d: "M20 6 9 17l-5-5"
        )
      end
    end

    def default_attrs
      {
        class: "group flex flex-row gap-2 items-center rounded-sm px-2 py-1.5 text-sm outline-none cursor-pointer select-none aria-selected:bg-accent hover:bg-accent p-2 [&>svg]:pointer-events-none [&>svg]:size-4 [&>svg]:shrink-0",
        role: "option",
        aria: {selected: @selected.to_s},
        data: {
          value: @value.to_s,
          ruby_ui__combobox_target: "datalistOption",
          action: "click->ruby-ui--combobox#toggleOption"
        }
      }
    end
  end
end
