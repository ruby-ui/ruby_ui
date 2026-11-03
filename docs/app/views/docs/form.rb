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
              FormFieldLabel(for: "default_error") { "Default error" }
              Input(id: "default_error", placeholder: "Joel Drapper", required: true, minlength: "3") { "Joel Drapper" }
              FormFieldHint()
              FormFieldError()
            end
            Button(type: "submit") { "Save" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Disabled", context: self) do
        <<~RUBY
          FormField(data: {disabled: "true"}) do
            FormFieldLabel(for: "disabled") { "Disabled" }
            Input(id: "disabled", disabled: true, placeholder: "Joel Drapper", required: true, minlength: "3") { "Joel Drapper" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Custom error message", context: self) do
        <<~RUBY
          Form(class: "w-2/3 space-y-6") do
            FormField do
              FormFieldLabel(for: "custom_error_message") { "Custom error message" }
              Input(id: "custom_error_message", placeholder: "joel@drapper.me", required: true, data_value_missing: "Custom error message")
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
              FormFieldLabel(for: "backend_error") { "Backend error" }
              Input(id: "backend_error", placeholder: "Joel Drapper", required: true)
              FormFieldError { "Error from backend" }
            end
            Button(type: "submit") { "Save" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Multiple errors", context: self) do
        <<~RUBY
          Form(class: "w-2/3 space-y-6") do
            FormField do
              FormFieldLabel(for: "multiple_errors") { "Username" }
              Input(id: "multiple_errors", value: "j!", required: true)
              # e.g. FormFieldError(errors: user.errors[:username])
              FormFieldError(errors: ["is too short (minimum is 3 characters)", "only allows letters and numbers"])
            end
            Button(type: "submit") { "Save" }
          end
        RUBY
      end

      Text do
        plain "Without a "
        InlineCode { "FormFieldError" }
        plain ", a "
        InlineCode { "FormField" }
        plain " leaves the message to the browser, which shows its native bubble next to the control. If a form mixes fields with and without "
        InlineCode { "FormFieldError" }
        plain ", focus goes to the first field with a bubble, which can come after the first invalid field."
      end

      render Docs::VisualCodeExample.new(title: "Checkbox", context: self) do
        <<~RUBY
          Form(class: "w-2/3 space-y-6") do
            FormField(orientation: :horizontal) do
              Checkbox(id: "accept_terms", required: true)
              FormFieldLabel(for: "accept_terms") { "Accept terms and conditions" }
            end
            Button(type: "submit") { "Save" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Fieldset", context: self) do
        <<~RUBY
          FormFieldSet(class: "w-2/3") do
            FormFieldLegend { "Address information" }
            FormFieldHint { "We need your address to deliver your order." }
            FormFieldGroup do
              FormField do
                FormFieldLabel(for: "fieldset_street") { "Street address" }
                Input(id: "fieldset_street", placeholder: "123 Main St")
              end
              FormField do
                FormFieldLabel(for: "fieldset_city") { "City" }
                Input(id: "fieldset_city", placeholder: "New York")
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Horizontal with description", context: self) do
        <<~RUBY
          FormField(orientation: :horizontal, class: "w-2/3") do
            Checkbox(id: "horizontal_newsletter")
            FormFieldContent do
              FormFieldLabel(for: "horizontal_newsletter") { "Subscribe to the newsletter" }
              FormFieldHint { "One email a month, no spam." }
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Responsive", context: self) do
        <<~RUBY
          FormFieldGroup do
            FormField(orientation: :responsive) do
              FormFieldContent do
                FormFieldLabel(for: "responsive_name") { "Name" }
                FormFieldHint { "Side by side on wide containers, stacked on narrow ones." }
              end
              Input(id: "responsive_name", placeholder: "Joel Drapper")
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Choice card", context: self) do
        <<~RUBY
          FormFieldGroup(class: "w-2/3") do
            FormFieldLabel(for: "plan_starter") do
              FormField(orientation: :horizontal) do
                FormFieldContent do
                  FormFieldTitle { "Starter" }
                  FormFieldHint { "For small teams getting started." }
                end
                RadioButton(id: "plan_starter", name: "plan", value: "starter", checked: true)
              end
            end
            FormFieldLabel(for: "plan_pro") do
              FormField(orientation: :horizontal) do
                FormFieldContent do
                  FormFieldTitle { "Pro" }
                  FormFieldHint { "For growing teams that need more." }
                end
                RadioButton(id: "plan_pro", name: "plan", value: "pro")
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Separator", context: self) do
        <<~RUBY
          FormFieldGroup(class: "w-2/3") do
            FormField do
              FormFieldLabel(for: "separator_email") { "Email" }
              Input(id: "separator_email", type: "email", placeholder: "joel@example.com")
            end
            FormFieldSeparator { "Or" }
            FormField do
              FormFieldLabel(for: "separator_phone") { "Phone" }
              Input(id: "separator_phone", type: "tel", placeholder: "+1 555 0100")
            end
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
              FormFieldLabel(for: "food-combobox") { "Combobox" }

              Combobox(name: "food", required: true) do
                ComboboxTrigger(id: "food-combobox") { ComboboxValue(placeholder: "Pick value") }

                ComboboxContent do
                  ComboboxInput(placeholder: "Search", show_trigger: false)
                  ComboboxEmpty { "No result" }

                  ComboboxList do
                    ComboboxGroup do
                      ComboboxLabel { "Fruits" }
                      ComboboxItem(value: "apple") { "Apple" }
                      ComboboxItem(value: "banana") { "Banana" }
                    end
                    ComboboxSeparator()
                    ComboboxGroup do
                      ComboboxLabel { "Vegetable" }
                      ComboboxItem(value: "brocoli") { "Broccoli" }
                      ComboboxItem(value: "carrot") { "Carrot" }
                    end
                    ComboboxSeparator()
                    ComboboxGroup do
                      ComboboxLabel { "Others" }
                      ComboboxItem(value: "chocolate") { "Chocolate" }
                      ComboboxItem(value: "milk") { "Milk" }
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

      Heading(level: 3) { "Minimal Rails form" }
      Codeblock(<<~RUBY, syntax: :ruby)
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

      Heading(level: 3) { "Devise-style login form" }
      Codeblock(<<~RUBY, syntax: :ruby)
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

          FormField(orientation: :horizontal) do
            Checkbox(id: "session_remember_me", name: "session[remember_me]", value: "1")
            FormFieldLabel(for: "session_remember_me") { "Remember me" }
          end

          Button(type: "submit", class: "w-full") { "Sign in" }
        end
      RUBY

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
