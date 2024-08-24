# frozen_string_literal: true

module Rbui
  class InputPreview < Lookbook::Preview
    # Email Input
    # ---------------
    def email
      render(TestView.new) do
        Input(type: "email", placeholder: "Email", class: "max-w-sm")
      end
    end

    # File input
    def file
      render(TestView.new) do
        Input(type: "file", id: "picture")
      end
    end

    # Disabled input
    def disabled
      render(TestView.new) do
        Input(disabled: true, type: "email", placeholder: "Email", class: "max-w-sm")
      end
    end

    # with error
    def with_error
      render(TestView.new) do
        Input(
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
