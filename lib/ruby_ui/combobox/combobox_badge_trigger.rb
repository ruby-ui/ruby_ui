# frozen_string_literal: true

module RubyUI
  class ComboboxBadgeTrigger < Base
    def initialize(placeholder: "", **)
      @placeholder = placeholder
      super(**)
    end

    def view_template(&)
      div(**attrs) do
        div(data: {ruby_ui__combobox_target: "badgeContainer"}, class: "contents")
        input(
          type: "text",
          class: "flex-1 min-w-[80px] bg-transparent outline-none placeholder:text-muted-foreground text-sm",
          autocomplete: "off",
          autocorrect: "off",
          spellcheck: "false",
          placeholder: @placeholder,
          data: {
            ruby_ui__combobox_target: "badgeInput",
            action: "keyup->ruby-ui--combobox#filterItems input->ruby-ui--combobox#filterItems keydown.backspace->ruby-ui--combobox#handleBadgeInputBackspace"
          }
        )
        yield if block_given?
        chevron_icon
      end
    end

    private

    def default_attrs
      {
        class: "flex min-h-9 w-full flex-wrap items-center gap-1 rounded-md border border-input bg-background px-3 py-1 text-sm ring-offset-background focus-within:ring-2 focus-within:ring-ring focus-within:ring-offset-2 cursor-text",
        data: {
          ruby_ui__combobox_target: "trigger",
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
