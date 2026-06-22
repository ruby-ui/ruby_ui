# frozen_string_literal: true

class Views::Docs::Form < Views::Base
  def view_template
    component = "Form"
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Form", description: "Building forms with built-in client-side validations.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Example", context: self) do
        <<~RUBY
          Form(class: "w-2/3 space-y-6") do
            FormField do
              FormFieldLabel { "Default error" }
              Input(placeholder: "Joel Drapper", required: true, minlength: "3") { "Joel Drapper" }
              FormFieldHint()
              FormFieldError()
            end
            Button(type: "submit") { "Save" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Disabled", context: self) do
        <<~RUBY
          FormField do
            FormFieldLabel { "Disabled" }
            Input(disabled: true, placeholder: "Joel Drapper", required: true, minlength: "3") { "Joel Drapper" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Aria Disabled", context: self) do
        <<~RUBY
          FormField do
            FormFieldLabel { "Aria Disabled" }
            Input(aria: {disabled: "true"}, placeholder: "Joel Drapper", required: true, minlength: "3") { "Joel Drapper" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Custom error message", context: self) do
        <<~RUBY
          Form(class: "w-2/3 space-y-6") do
            FormField do
              FormFieldLabel { "Custom error message" }
              Input(placeholder: "joel@drapper.me", required: true, data_value_missing: "Custom error message")
              FormFieldError()
            end
            Button(type: "submit") { "Save" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Backend error", context: self) do
        <<~RUBY
          Form(class: "w-2/3 space-y-6") do
            FormField do
              FormFieldLabel { "Backend error" }
              Input(placeholder: "Joel Drapper", required: true)
              FormFieldError { "Error from backend" }
            end
            Button(type: "submit") { "Save" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Checkbox", context: self) do
        <<~RUBY
          Form(class: "w-2/3 space-y-6") do
            FormField do
              Checkbox(required: true)
                label(
                  class:
                    "text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
                ) { " Accept terms and conditions " }
              FormFieldError()
            end
            Button(type: "submit") { "Save" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Select", context: self) do
        <<~RUBY
          Form(class: "w-2/3 space-y-6") do
            FormField do
              FormFieldLabel { "Select" }
              Select do
                SelectInput(required: true)
                SelectTrigger do
                  SelectValue(placeholder: "Select a fruit")
                end
                SelectContent() do
                  SelectGroup do
                    SelectLabel { "Fruits" }
                    SelectItem(value: "apple") { "Apple" }
                    SelectItem(value: "orange") { "Orange" }
                    SelectItem(value: "banana") { "Banana" }
                    SelectItem(value: "watermelon") { "Watermelon" }
                  end
                end
              end
              FormFieldError()
            end
            Button(type: "submit") { "Save" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Combobox", context: self) do
        <<~RUBY
          Form(class: "w-2/3 space-y-6") do
            FormField do
              FormFieldLabel { "Combobox" }

              Combobox do
                ComboboxTrigger placeholder: "Pick value"

                ComboboxPopover do
                  ComboboxSearchInput(placeholder: "Pick value or type anything")

                  ComboboxList do
                    ComboboxEmptyState { "No result" }

                    ComboboxListGroup label: "Fruits" do
                      ComboboxItem do
                        ComboboxRadio(name: "food", value: "apple", required: true)
                        span { "Apple" }
                      end

                      ComboboxItem do
                        ComboboxRadio(name: "food", value: "banana", required: true)
                        span { "Banana" }
                      end
                    end

                    ComboboxListGroup label: "Vegetable" do
                      ComboboxItem do
                        ComboboxRadio(name: "food", value: "brocoli", required: true)
                        span { "Broccoli" }
                      end

                      ComboboxItem do
                        ComboboxRadio(name: "food", value: "carrot", required: true)
                        span { "Carrot" }
                      end
                    end

                    ComboboxListGroup label: "Others" do
                      ComboboxItem do
                        ComboboxRadio(name: "food", value: "chocolate", required: true)
                        span { "Chocolate" }
                      end

                      ComboboxItem do
                        ComboboxRadio(name: "food", value: "milk", required: true)
                        span { "Milk" }
                      end
                    end
                  end
                end
              end

              FormFieldError()
            end
            Button(type: "submit") { "Save" }
          end
        RUBY
      end

      Heading(level: 2) { "Rails Integration" }

      Text do
        plain "RubyUI Form components are plain HTML — they work with any form submission strategy. "
        plain "The recommended approach for Rails apps is to use "
        InlineLink(href: "https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-form_with", target: "_blank") { "form_with" }
        plain " to generate the "
        code(class: "font-mono text-sm") { "action" }
        plain " URL and CSRF token, then pass explicit "
        code(class: "font-mono text-sm") { "name" }
        plain " / "
        code(class: "font-mono text-sm") { "id" }
        plain " attributes to each RubyUI input so the browser serialises them correctly. "
        plain "Server-side errors can be surfaced by rendering "
        code(class: "font-mono text-sm") { "FormFieldError" }
        plain " with content from "
        code(class: "font-mono text-sm") { "model.errors.full_messages_for(:attr)" }
        plain "."
      end

      render Docs::VisualCodeExample.new(title: "Minimal Rails form", context: self) do
        <<~RUBY
          # In your Phlex view, call form_with via helpers:
          # form_with(url: users_path, method: :post) passes action + CSRF automatically.
          #
          # You can also set action and the CSRF token manually:
          Form(action: helpers.users_path, method: "post", class: "w-2/3 space-y-6") do
            input(type: "hidden", name: "authenticity_token", value: helpers.form_authenticity_token)

            FormField do
              FormFieldLabel(for: "user_email") { "Email" }
              Input(
                type: "email",
                id: "user_email",
                name: "user[email]",
                placeholder: "you@example.com",
                required: true
              )
              FormFieldError()
            end

            Button(type: "submit") { "Continue" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Devise-style login form", context: self) do
        <<~RUBY
          # Full sign-in form mirroring Devise session[email] / session[password] params.
          # Pass backend errors (e.g. "Invalid email or password") into FormFieldError.
          Form(action: helpers.user_session_path, method: "post", class: "space-y-6") do
            input(type: "hidden", name: "authenticity_token", value: helpers.form_authenticity_token)

            FormField do
              FormFieldLabel(for: "session_email") { "Email" }
              Input(
                type: "email",
                id: "session_email",
                name: "session[email]",
                placeholder: "you@example.com",
                autocomplete: "email",
                required: true
              )
              FormFieldError { @error_message }
            end

            FormField do
              FormFieldLabel(for: "session_password") { "Password" }
              Input(
                type: "password",
                id: "session_password",
                name: "session[password]",
                autocomplete: "current-password",
                required: true,
                minlength: "8"
              )
              FormFieldError()
            end

            FormField do
              div(class: "flex items-center gap-2") do
                Checkbox(id: "session_remember_me", name: "session[remember_me]", value: "1")
                FormFieldLabel(for: "session_remember_me") { "Remember me" }
              end
            end

            Button(type: "submit", class: "w-full") { "Sign in" }
          end
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
