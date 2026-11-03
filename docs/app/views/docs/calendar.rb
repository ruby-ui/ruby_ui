# frozen_string_literal: true

class Views::Docs::Calendar < Views::Base
  def view_template
    component = "Calendar"
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Calendar", description: "A calendar that lets users pick a date, with keyboard navigation.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Connect to input", context: self) do
        <<~RUBY
          div(class: 'space-y-4') do
            Input(placeholder: "Select a date", class: 'rounded-md border shadow', id: 'date', data_controller: 'ruby-ui--calendar-input')
            Calendar(input_id: '#date', class: 'rounded-md border shadow')
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Format date", description: "Format dates with date-fns", context: self) do
        <<~RUBY
          div(class: 'space-y-4') do
            Input(placeholder: "Select a date", class: 'rounded-md border shadow', id: 'formatted-date', data_controller: 'ruby-ui--calendar-input')
            Calendar(input_id: '#formatted-date', date_format: 'PPPP', class: 'rounded-md border shadow')
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Minimum date", description: "Disable dates before a given date", context: self) do
        <<~RUBY
          div(class: 'space-y-4') do
            Input(placeholder: "Select a date", class: 'rounded-md border shadow', id: 'minimum-date', data_controller: 'ruby-ui--calendar-input')
            Calendar(input_id: '#minimum-date', min_date: Date.current, class: 'rounded-md border shadow')
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Week start", description: "Weeks start on Sunday by default; pass week_starts_on to change it", context: self) do
        <<~RUBY
          Calendar(week_starts_on: :monday, class: 'rounded-md border shadow')
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
