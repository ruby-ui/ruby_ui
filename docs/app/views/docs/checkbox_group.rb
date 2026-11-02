# frozen_string_literal: true

class Views::Docs::CheckboxGroup < Views::Base
  def view_template
    component = "Checkbox"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Checkbox Group", description: "A set of checkboxes that can require at least one to be checked.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Example", context: self) do
        <<~RUBY
          FormFieldSet do
            FormFieldLegend(variant: :label) { "Show these items on the desktop:" }

            CheckboxGroup do
              FormField(orientation: :horizontal) do
                Checkbox(id: "hard_disks", checked: true)
                FormFieldLabel(for: "hard_disks", class: "font-normal") { "Hard disks" }
              end

              FormField(orientation: :horizontal) do
                Checkbox(id: "external_disks")
                FormFieldLabel(for: "external_disks", class: "font-normal") { "External disks" }
              end

              FormField(orientation: :horizontal) do
                Checkbox(id: "connected_servers")
                FormFieldLabel(for: "connected_servers", class: "font-normal") { "Connected servers" }
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Required", context: self) do
        <<~RUBY
          form(class: "flex flex-col gap-6") do
            FormFieldSet do
              FormFieldLegend(variant: :label) { "Notifications" }
              FormFieldHint { "Pick at least one channel." }

              CheckboxGroup(required: true) do
                FormField(orientation: :horizontal) do
                  Checkbox(id: "notify_email", name: "notify[]", value: "email")
                  FormFieldLabel(for: "notify_email", class: "font-normal") { "Email" }
                end

                FormField(orientation: :horizontal) do
                  Checkbox(id: "notify_sms", name: "notify[]", value: "sms")
                  FormFieldLabel(for: "notify_sms", class: "font-normal") { "SMS" }
                end
              end
            end

            Button(type: "submit", class: "w-fit") { "Save" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "With error message", context: self) do
        <<~RUBY
          form(class: "flex flex-col gap-6") do
            FormField do
              FormFieldLabel { "Topics" }
              FormFieldHint { "Pick at least one topic." }

              CheckboxGroup(required: true) do
                div(class: "flex items-center gap-3") do
                  Checkbox(
                    id: "topic_rails",
                    name: "topics[]",
                    value: "rails",
                    data: {value_missing: "Pick at least one topic."}
                  )
                  FormFieldLabel(for: "topic_rails", class: "font-normal") { "Rails" }
                end

                div(class: "flex items-center gap-3") do
                  Checkbox(
                    id: "topic_hotwire",
                    name: "topics[]",
                    value: "hotwire",
                    data: {value_missing: "Pick at least one topic."}
                  )
                  FormFieldLabel(for: "topic_hotwire", class: "font-normal") { "Hotwire" }
                end
              end

              FormFieldError()
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
