# frozen_string_literal: true

class Views::Docs::DatePicker < Views::Base
  def view_template
    component = "DatePicker"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Date Picker", description: "A date picker component with input.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Single Date", context: self) do
        <<~RUBY
          DatePicker(id: "date")
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
