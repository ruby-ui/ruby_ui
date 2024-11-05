# frozen_string_literal: true

module RubyUI
  class ComboboxSearchInput < Base
    def initialize(placeholder:, **attrs)
      @placeholder = placeholder
      super(**attrs)
    end

    def view_template
      input_container do
        search_icon
        input(**attrs)
      end
    end

    private

    def search_icon
      svg(
        xmlns: "http://www.w3.org/2000/svg",
        viewbox: "0 0 24 24",
        fill: "none",
        stroke: "currentColor",
        class: "mr-2 h-4 w-4 shrink-0 opacity-50",
        stroke_width: "2",
        stroke_linecap: "round",
        stroke_linejoin: "round"
      ) do |s|
        s.circle(cx: "11", cy: "11", r: "8")
        s.path(
          d: "m21 21-4.3-4.3"
        )
      end
    end

    def input_container(&)
      div(class: "flex items-center border-b px-3", &)
    end

    def default_attrs
      {
        class:
          "flex h-10 w-full rounded-md bg-transparent py-3 text-sm outline-none placeholder:text-muted-foreground disabled:cursor-not-allowed disabled:opacity-50",
        placeholder: @placeholder,
        data: {
          action: "input->ruby_ui--combobox#onSearchInput",
          ruby_ui__combobox_target: "search"
        },
        autocomplete: "off",
        autocorrect: "off",
        spellcheck: false
      }
    end
  end
end
