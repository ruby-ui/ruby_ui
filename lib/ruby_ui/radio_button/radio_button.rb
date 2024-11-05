# frozen_string_literal: true

module RubyUI
  class RadioButton < Base
    def view_template
      input(**attrs)
    end

    private

    def default_attrs
      {
        type: "radio",
        data: {
          rbui__form_field_target: "input",
          action: "input->rbui--form-field#onInput invalid->rbui--form-field#onInvalid"
        },
        class: "h-4 w-4 p-0 border-primary rounded-full flex-none"
      }
    end
  end
end
