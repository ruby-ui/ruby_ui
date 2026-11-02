# frozen_string_literal: true

module RubyUI
  # The text input after the chips. Backspace on an empty input removes the
  # last chip.
  class ComboboxChipsInput < Base
    include ComboboxContext

    def initialize(placeholder: nil, disabled: false, **)
      @placeholder = placeholder
      @disabled = disabled
      super(**)
    end

    def view_template
      input(**with_combobox_defaults(disabled: @disabled || !!combobox[:disabled], aria: {controls: combobox[:list_id], required: (combobox[:required] ? "true" : nil)}))
    end

    private

    def default_attrs
      {
        type: "text",
        role: "combobox",
        placeholder: @placeholder,
        autocomplete: "off",
        autocorrect: "off",
        spellcheck: "false",
        autocapitalize: "none",
        aria: {autocomplete: "list", expanded: "false", haspopup: "listbox"},
        class: "min-w-16 flex-1 border-0 bg-transparent p-0 text-sm outline-none ring-0 focus:ring-0 placeholder:text-muted-foreground disabled:cursor-not-allowed",
        data: {
          slot: "combobox-chip-input",
          ruby_ui__combobox_target: "input",
          action: "input->ruby-ui--combobox#filter keydown->ruby-ui--combobox#inputKeydown " \
            "click->ruby-ui--combobox#inputClick"
        }
      }
    end
  end
end
