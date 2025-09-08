# frozen_string_literal: true

module RubyUI
  class ComboboxTrigger < Base
    def initialize(placeholder: "", **)
      @placeholder = placeholder
      super(**)
    end

    def view_template
      button(**attrs) do
        span(class: "truncate", data: {ruby_ui__combobox_target: "triggerContent"}) do
          @placeholder
        end
        icon
      end
    end

    private

    def default_attrs
      {
        type: "button",
        class: [
          "flex h-full w-full items-center whitespace-nowrap rounded-md text-sm ring-offset-background transition-colors border border-input bg-background h-9 px-4 py-2 justify-between",
          "hover:bg-accent hover:text-accent-foreground",
          "disabled:pointer-events-none disabled:opacity-50",
          "aria-disabled:pointer-events-none aria-disabled:opacity-50 aria-disabled:cursor-not-allowed",
          "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
        ],
        data: {
          placeholder: @placeholder,
          ruby_ui__combobox_target: "trigger",
          action: "ruby-ui--combobox#openPopover"
        },
        aria: {
          haspopup: "listbox",
          expanded: "false"
        }
      }
    end

    def icon
      svg(
        xmlns: "http://www.w3.org/2000/svg",
        viewbox: "0 0 24 24",
        fill: "none",
        stroke: "currentColor",
        class: "ml-2 h-4 w-4 shrink-0 opacity-50",
        stroke_width: "2",
        stroke_linecap: "round",
        stroke_linejoin: "round"
      ) do |s|
        s.path(
          d: "m7 15 5 5 5-5"
        )
        s.path(
          d: "m7 9 5-5 5 5"
        )
      end
    end
  end
end
