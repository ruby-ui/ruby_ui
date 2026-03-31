# frozen_string_literal: true

module RubyUI
  class ComboboxInputTrigger < Base
    def initialize(placeholder: "", **)
      @placeholder = placeholder
      super(**)
    end

    def view_template
      div(**attrs) do
        input(
          type: "text",
          placeholder: @placeholder,
          autocomplete: "off",
          autocorrect: "off",
          spellcheck: "false",
          class: "flex-1 border-0 bg-transparent outline-none focus:ring-0 placeholder:text-muted-foreground text-sm disabled:cursor-not-allowed",
          data: {
            ruby_ui__combobox_target: "inputTrigger",
            action: "keyup->ruby-ui--combobox#filterItems input->ruby-ui--combobox#filterItems"
          }
        )
        chevron_icon
      end
    end

    private

    def default_attrs
      {
        class: "flex h-9 w-full items-center rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background focus-within:ring-2 focus-within:ring-ring focus-within:ring-offset-2 aria-invalid:border-destructive",
        data: {
          ruby_ui__combobox_target: "trigger",
          placeholder: @placeholder,
          action: "click->ruby-ui--combobox#openPopover"
        },
        aria: {
          haspopup: "listbox",
          expanded: "false"
        }
      }
    end

    def chevron_icon
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
        s.path(d: "m7 15 5 5 5-5")
        s.path(d: "m7 9 5-5 5 5")
      end
    end
  end
end
