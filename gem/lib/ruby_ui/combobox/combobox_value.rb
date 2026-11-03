# frozen_string_literal: true

module RubyUI
  # Shows the selected item(s) inside ComboboxTrigger. The controller fills it:
  # the placeholder when nothing is selected, the item text, the texts joined
  # with ", " (multiple), or "<count> <term>" when the root has term:.
  class ComboboxValue < Base
    def initialize(placeholder: nil, **)
      @placeholder = placeholder
      super(**)
    end

    def view_template
      span(**attrs) { @placeholder }
    end

    private

    def default_attrs
      {
        class: "truncate data-placeholder:text-muted-foreground",
        data: {
          slot: "combobox-value",
          ruby_ui__combobox_target: "value",
          placeholder_text: @placeholder,
          placeholder: ""
        }
      }
    end
  end
end
