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
          class: "flex-1 border-0 px-0 bg-transparent outline-none focus:ring-0 placeholder:text-muted-foreground text-sm disabled:cursor-not-allowed",
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
          action: "click->ruby-ui--combobox#openPopover focusin->ruby-ui--combobox#openPopover"
        },
        aria: {
          haspopup: "listbox",
          expanded: "false"
        }
      }
    end

    def chevron_icon
      span(class: "shrink-0 flex items-center justify-center size-6 rounded-sm hover:bg-muted hover:text-foreground") do
        svg(
          xmlns: "http://www.w3.org/2000/svg",
          width: "24",
          height: "24",
          viewbox: "0 0 24 24",
          fill: "none",
          stroke: "currentColor",
          stroke_width: "2",
          stroke_linecap: "round",
          stroke_linejoin: "round",
          class: "pointer-events-none size-4 text-muted-foreground"
        ) do |s|
          s.path(d: "m6 9 6 6 6-6")
        end
      end
    end
  end
end
