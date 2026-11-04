# frozen_string_literal: true

class Views::Docs::RadioButton < Views::Base
  def view_template
    component = "RadioButton"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Radio Button", description: "A set of checkable buttons, known as radio buttons, where no more than one can be checked at a time.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Example", description: "Radios with the same name: form one group. RadioGroup adds role=\"radiogroup\"; name it with aria: {label:} or aria: {labelledby:}.", context: self) do
        <<~RUBY
          RadioGroup(class: "w-fit", aria: {label: "Density"}) do
            div(class: "flex items-center gap-3") do
              RadioButton(id: "density_default", name: "density", value: "default")
              FormFieldLabel(for: "density_default") { "Default" }
            end
            div(class: "flex items-center gap-3") do
              RadioButton(id: "density_comfortable", name: "density", value: "comfortable", checked: true)
              FormFieldLabel(for: "density_comfortable") { "Comfortable" }
            end
            div(class: "flex items-center gap-3") do
              RadioButton(id: "density_compact", name: "density", value: "compact")
              FormFieldLabel(for: "density_compact") { "Compact" }
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Disabled", context: self) do
        <<~RUBY
          RadioGroup(class: "w-fit", aria: {label: "Plan"}) do
            div(class: "flex items-center gap-3") do
              RadioButton(id: "plan_free", name: "plan_disabled", value: "free", checked: true)
              FormFieldLabel(for: "plan_free") { "Free" }
            end
            div(class: "flex items-center gap-3") do
              RadioButton(id: "plan_enterprise", name: "plan_disabled", value: "enterprise", disabled: true)
              FormFieldLabel(for: "plan_enterprise") { "Enterprise" }
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Invalid", context: self) do
        <<~RUBY
          RadioGroup(class: "w-fit", aria: {label: "Notifications"}) do
            div(class: "flex items-center gap-3") do
              RadioButton(id: "notify_all", name: "notify_invalid", value: "all", aria: {invalid: "true"})
              FormFieldLabel(for: "notify_all") { "All new messages" }
            end
            div(class: "flex items-center gap-3") do
              RadioButton(id: "notify_none", name: "notify_invalid", value: "none", aria: {invalid: "true"})
              FormFieldLabel(for: "notify_none") { "Nothing" }
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Required", description: "required: on each radio makes the browser ask for one of them. FormField shows the message and marks the radios invalid.", context: self) do
        <<~RUBY
          form(class: "flex w-fit flex-col gap-4") do
            FormFieldSet do
              FormFieldLegend(id: "notify_legend", variant: :label) { "Notify me about" }
              FormField do
                RadioGroup(aria: {labelledby: "notify_legend"}) do
                  div(class: "flex items-center gap-3") do
                    RadioButton(id: "notify_mentions", name: "notify", value: "mentions", required: true)
                    FormFieldLabel(for: "notify_mentions") { "Direct messages and mentions" }
                  end
                  div(class: "flex items-center gap-3") do
                    RadioButton(id: "notify_nothing", name: "notify", value: "nothing", required: true)
                    FormFieldLabel(for: "notify_nothing") { "Nothing" }
                  end
                end
                FormFieldError()
              end
            end
            Button(type: "submit", class: "w-fit") { "Save" }
          end
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
