# frozen_string_literal: true

module RubyUI
  class ComboboxLabel < Base
    def view_template(&)
      label_id = context[:ruby_ui_combobox_group]&.dig(:label_id)
      label_attrs = (label_id && !attrs[:id]) ? attrs.merge(id: label_id) : attrs
      div(**label_attrs, &)
    end

    private

    def default_attrs
      {
        # The group is named through aria-labelledby; the text itself is hidden.
        aria: {hidden: "true"},
        data: {slot: "combobox-label"},
        class: "px-2 py-1.5 text-xs text-muted-foreground"
      }
    end
  end
end
