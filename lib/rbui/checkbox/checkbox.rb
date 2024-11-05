# frozen_string_literal: true

module RBUI
  class Checkbox < Base
    def view_template
      input(**attrs)
    end

    private

    def default_attrs
      {
        type: "checkbox",
        data: {
          rbui__form_field_target: "input",
          rbui__checkbox_group_target: "checkbox",
          action: "change->rbui--checkbox-group#onChange change->rbui--form-field#onInput invalid->rbui--form-field#onInvalid"
        },
        class: "peer h-4 w-4 shrink-0 rounded-sm border border-primary ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50 accent-primary"
      }
    end
  end
end
