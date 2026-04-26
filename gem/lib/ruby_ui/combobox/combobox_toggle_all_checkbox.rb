# frozen_string_literal: true

module RubyUI
  class ComboboxToggleAllCheckbox < Base
    def view_template
      input(type: "checkbox", **attrs)
    end

    private

    def default_attrs
      {
        class: "peer sr-only disabled:cursor-not-allowed",
        data: {
          ruby_ui__combobox_target: "toggleAll",
          action: "change->ruby-ui--combobox#toggleAllItems"
        }
      }
    end
  end
end
