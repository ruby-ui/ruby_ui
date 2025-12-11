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

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
