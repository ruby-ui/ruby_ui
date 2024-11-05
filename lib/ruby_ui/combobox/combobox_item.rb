# frozen_string_literal: true

module RubyUI
  class ComboboxItem < Base
    def initialize(value: nil, **attrs)
      @value = value
      super(**attrs)
    end

    def view_template(&block)
      div(**attrs) do
        div(class: "invisible group-aria-selected:visible") { icon }
        block.call
      end
    end

    private

    def icon
      svg(
        xmlns: "http://www.w3.org/2000/svg",
        viewbox: "0 0 24 24",
        fill: "none",
        stroke: "currentColor",
        class: "mr-2 h-4 w-4",
        stroke_width: "2",
        stroke_linecap: "round",
        stroke_linejoin: "round"
      ) do |s|
        s.path(
          d: "M20 6 9 17l-5-5"
        )
      end
    end

    def default_attrs
      {
        role: "option",
        tabindex: "0",
        class:
          "combobox-item group relative flex cursor-pointer select-none items-center gap-x-2 rounded-sm px-2 py-1.5 text-sm outline-none hover:bg-accent hover:text-accent-foreground aria-[current]:bg-accent aria-[current]:text-accent-foreground data-[disabled]:pointer-events-none data-[disabled]:opacity-50",
        data: {
          value: @value,
          ruby_ui__combobox_target: "item",
          ruby_ui__combobox_content_target: "item",
          controller: "ruby_ui--combobox-item",
          action: "click->ruby_ui--combobox#onItemSelected"
        },
        aria_selected: "false"
      }
    end
  end
end
