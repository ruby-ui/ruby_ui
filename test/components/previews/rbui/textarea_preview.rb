# frozen_string_literal: true

module RBUI
  class TextareaPreview < Lookbook::Preview
    # Email Textarea
    # ---------------
    def email
      render(TestView.new) do
        Textarea(type: "email", placeholder: "Email", class: "max-w-sm")
      end
    end

    # Disabled Textarea
    def disabled
      render(TestView.new) do
        Textarea(disabled: true, type: "email", placeholder: "Email", class: "max-w-sm")
      end
    end

    # with error
    def with_error
      render(TestView.new) do
        Textarea(
          type: "email",
          placeholder: "Email",
          id: "email1",
          value: "joel@mail",
          error: "Invalid email address"
        )
      end
    end
  end
end
