# frozen_string_literal: true

class Views::Docs::DatePicker < Views::Base
  def view_template
    component = "DatePicker"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Date Picker", description: "A date picker component with input.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Single Date", context: self) do
        <<~RUBY
          div(class: 'space-y-4 w-[260px]') do
            Popover(options: { trigger: 'click' }) do
              PopoverTrigger(class: 'w-full') do
                div(class: 'grid w-full max-w-sm items-center gap-1.5') do
                  label(for: "date") { "Select a date" }
                  Input(type: 'string', placeholder: "Select a date", class: 'rounded-md border shadow', id: 'date', data_controller: 'ruby-ui--calendar-input')
                end
              end
              PopoverContent do
                Calendar(input_id: '#date')
              end
            end
          end
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
