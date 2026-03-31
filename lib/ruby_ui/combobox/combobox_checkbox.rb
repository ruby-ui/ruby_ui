# frozen_string_literal: true

module RubyUI
  class ComboboxCheckbox < Base
    def view_template
      input(type: "checkbox", **attrs)
    end

    private

    def default_attrs
      {
        class: "peer sr-only",
        data: {
          ruby_ui__combobox_target: "input",
          action: "ruby-ui--combobox#inputChanged"
        }
      }
    end
  end
end
