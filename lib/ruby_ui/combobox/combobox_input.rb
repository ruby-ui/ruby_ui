# frozen_string_literal: true

module RubyUI
  class ComboboxInput < Base
    def view_template
      input(**attrs)
    end

    private

    def default_attrs
      {
        class: "hidden",
        data: {
          ruby_ui__combobox_target: "input",
          ruby_ui__form_field_target: "input",
          action: "change->ruby_ui--form-field#onChange invalid->ruby_ui--form-field#onInvalid"
        }
      }
    end
  end
end
