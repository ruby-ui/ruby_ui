# frozen_string_literal: true

module RubyUI
  class ComboboxRadio < Base
    def view_template
      input(type: "radio", **attrs)
    end

    private

    def default_attrs
      {
        class: "peer sr-only",
        data: {
          ruby_ui__combobox_target: "input",
          ruby_ui__form_field_target: "input",
          action: %w[
            ruby-ui--combobox#inputChanged
            input->ruby-ui--form-field#onInput
            invalid->ruby-ui--form-field#onInvalid
          ]
        }
      }
    end
  end
end
