# frozen_string_literal: true

module RubyUI
  class FormFieldError
    include ComponentBase

    private

    def default_attrs
      {
        data: {
          ruby_ui__form_field_target: "error"
        },
        class: "empty:hidden text-sm font-medium text-destructive"
      }
    end
  end
end
