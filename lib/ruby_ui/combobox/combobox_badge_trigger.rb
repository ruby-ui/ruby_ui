# frozen_string_literal: true

module RubyUI
  class ComboboxBadgeTrigger < Base
    def initialize(placeholder: "", clear_button: false, **)
      @placeholder = placeholder
      @clear_button = clear_button
      super(**)
    end

    def view_template(&)
      div(**attrs) do
        div(data: {ruby_ui__combobox_target: "badgeContainer"}, class: "hidden")
        input(
          type: "text",
          class: "flex-1 min-w-8 bg-transparent border-0 px-0 outline-none focus:ring-0 placeholder:text-muted-foreground text-sm",
          autocomplete: "off",
          autocorrect: "off",
          spellcheck: "false",
          placeholder: @placeholder,
          data: {
            ruby_ui__combobox_target: "badgeInput",
            action: "keyup->ruby-ui--combobox#filterItems input->ruby-ui--combobox#filterItems keydown.backspace->ruby-ui--combobox#handleBadgeInputBackspace"
          }
        )
        render ComboboxClearButton.new if @clear_button
      end
    end

    private

    # JS-toggled classes (referenced here so Tailwind compiles them): h-auto min-h-9 pt-1.5
    def default_attrs
      {
        class: "flex h-9 w-full flex-wrap items-center gap-1 rounded-md border border-input bg-background px-3 text-sm ring-offset-background focus-within:ring-2 focus-within:ring-ring focus-within:ring-offset-2 cursor-text",
        data: {
          ruby_ui__combobox_target: "trigger",
          action: "click->ruby-ui--combobox#openPopover focusin->ruby-ui--combobox#openPopover"
        },
        aria: {
          haspopup: "listbox",
          expanded: "false"
        }
      }
    end
  end
end
