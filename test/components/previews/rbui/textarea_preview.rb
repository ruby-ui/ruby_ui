# frozen_string_literal: true

module RBUI
  class TextareaPreview < Lookbook::Preview
    # Default
    # ---------------
    def default
      render(TestView.new) do
        Textarea(placeholder: "Textarea")
      end
    end

    # Disabled
    def disabled
      render(TestView.new) do
        Textarea(disabled: true, placeholder: "Disabled")
      end
    end

    # FormField
    def with_error
      render(TestView.new) do
        FormField do
          FormFieldLabel(for: "textarea") { "Textarea"}
          FormFieldHint { "This is a textarea" }
          Textarea(placeholder: "Textarea", id: "textarea")
          FormFieldError { "This is an error message" }
        end
      end
    end
  end
end
