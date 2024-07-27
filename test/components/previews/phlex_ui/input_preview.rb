# frozen_string_literal: true

module PhlexUi
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
        FormItem do
          Label(for: "picture") { "Picture" }
          Input(type: "file", id: "picture")
        end
      end
    end

    # Disabled input
    def disabled
      render(TestView.new) do
        Input(disabled: true, type: "email", placeholder: "Email", class: "max-w-sm")
      end
    end

    # with label
    def with_label
      render(TestView.new) do
        FormItem do
          Label(for: "email1") { "Email" }
          Input(type: "email", placeholder: "Email", id: "email1")
        end
      end
    end

    # with error
    def with_error
      render(TestView.new) do
        FormItem do
          Label(for: "email1") { "Email" }
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

    # with button
    def with_button
      render(TestView.new) do
        Form(class: "w-full max-w-sm") do
          FormSpacer do
            FormItem do
              Label(for: "username") { "Username" }
              Input(type: "string", placeholder: "Username", id: "username")
              Hint { "Can only contain letters, numbers, and underscores." }
            end

            Button(type: "submit") { "Submit" }
          end
        end
      end
    end
  end
end
