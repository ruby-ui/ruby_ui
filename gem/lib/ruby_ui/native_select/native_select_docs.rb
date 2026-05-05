# frozen_string_literal: true

class Views::Docs::NativeSelect < Views::Base
  def view_template
    component = "NativeSelect"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Native Select", description: "A styled native HTML select element with consistent design system integration.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Default", context: self) do
        <<~RUBY
          div(class: "grid w-full max-w-sm items-center gap-1.5") do
            NativeSelect do
              NativeSelectOption(value: "") { "Select a fruit" }
              NativeSelectOption(value: "apple") { "Apple" }
              NativeSelectOption(value: "banana") { "Banana" }
              NativeSelectOption(value: "blueberry") { "Blueberry" }
              NativeSelectOption(value: "pineapple") { "Pineapple" }
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Groups", description: "Use NativeSelectGroup to organize options into categories.", context: self) do
        <<~RUBY
          div(class: "grid w-full max-w-sm items-center gap-1.5") do
            NativeSelect do
              NativeSelectOption(value: "") { "Select a department" }
              NativeSelectGroup(label: "Engineering") do
                NativeSelectOption(value: "frontend") { "Frontend" }
                NativeSelectOption(value: "backend") { "Backend" }
                NativeSelectOption(value: "devops") { "DevOps" }
              end
              NativeSelectGroup(label: "Sales") do
                NativeSelectOption(value: "account_executive") { "Account Executive" }
                NativeSelectOption(value: "sales_development") { "Sales Development" }
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Disabled", description: "Add the disabled attribute to the NativeSelect component to disable the select.", context: self) do
        <<~RUBY
          div(class: "grid w-full max-w-sm items-center gap-1.5") do
            NativeSelect(disabled: true) do
              NativeSelectOption(value: "") { "Select a fruit" }
              NativeSelectOption(value: "apple") { "Apple" }
              NativeSelectOption(value: "banana") { "Banana" }
              NativeSelectOption(value: "blueberry") { "Blueberry" }
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Invalid", description: "Use aria-invalid to show validation errors.", context: self) do
        <<~RUBY
          div(class: "grid w-full max-w-sm items-center gap-1.5") do
            NativeSelect(aria: {invalid: "true"}) do
              NativeSelectOption(value: "") { "Select a fruit" }
              NativeSelectOption(value: "apple") { "Apple" }
              NativeSelectOption(value: "banana") { "Banana" }
              NativeSelectOption(value: "blueberry") { "Blueberry" }
            end
          end
        RUBY
      end

      Heading(level: 2) { "Native Select vs Select" }

      div(class: "space-y-2 text-sm text-muted-foreground") do
        p { "NativeSelect: Choose for native browser behavior, superior performance, or mobile-optimized dropdowns." }
        p { "Select: Choose for custom styling, animations, or complex interactions." }
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
