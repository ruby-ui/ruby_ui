# frozen_string_literal: true

class Views::Docs::Calendar < Views::Base
  def view_template
    component = "Calendar"
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Calendar", description: "A date field component that allows users to enter and edit date.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Connect to input", context: self) do
        <<~RUBY
          div(class: 'space-y-4') do
            Input(type: 'string', placeholder: "Select a date", class: 'rounded-md border shadow', id: 'date', data_controller: 'ruby-ui--calendar-input')
            Calendar(input_id: '#date', class: 'rounded-md border shadow')
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Format date", description: "Format dates with date-fns", context: self) do
        <<~RUBY
          div(class: 'space-y-4') do
            Input(type: 'string', placeholder: "Select a date", class: 'rounded-md border shadow', id: 'formatted-date', data_controller: 'ruby-ui--calendar-input')
            Calendar(input_id: '#formatted-date', date_format: 'PPPP', class: 'rounded-md border shadow')
          end
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
