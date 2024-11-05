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
          rbui__combobox_target: "input",
          rbui__form_field_target: "input",
          action: "change->rbui--form-field#onChange invalid->rbui--form-field#onInvalid"
        }
      }
    end
  end
end
