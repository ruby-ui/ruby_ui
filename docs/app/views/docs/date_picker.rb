# frozen_string_literal: true

class Views::Docs::DatePicker < Views::Base
  def view_template
    component = "DatePicker"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Date Picker", description: "A date field with an input and a calendar in a popover.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Input", description: "Type a date or open the calendar with the button (or ArrowDown in the input). Picking a day writes it into the input, in date_format:, and a date typed in that format moves the calendar to it.", context: self) do
        <<~RUBY
          div(class: "w-48") do
            DatePicker(id: "date", name: "date", label: "Subscription Date", placeholder: "yyyy-mm-dd")
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Selected date", description: "selected_date: fills the input and selects the day in the calendar.", context: self) do
        <<~RUBY
          div(class: "w-48") do
            DatePicker(id: "date-selected", name: "date_selected", label: "Due date", selected_date: Date.new(2026, 3, 12))
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Date format", description: "date_format: sets how the picked date is written (yyyy, MM, dd, MMMM, EEEE, do, PPPP).", context: self) do
        <<~RUBY
          div(class: "w-72") do
            DatePicker(id: "date-format", label: "Event", date_format: "PPPP")
          end
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
