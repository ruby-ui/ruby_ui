# frozen_string_literal: true

class Docs::DatePickerView < ApplicationView
  def view_template
    component = "Date Picker"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Date Picker", description: "A date picker component with input.")

      TypographyH2 { "Usage" }

      render Docs::VisualCodeExample.new(title: "Single Date", context: self) do
        <<~RUBY
          div(class: 'space-y-4 w-[260px]') do
            Popover(options: { trigger: 'focusin' }) do
              PopoverTrigger(class: 'w-full') do
                div(class: 'grid w-full max-w-sm items-center gap-1.5') do
                  label(for: "date") { "Select a date" }
                  Input(type: 'string', placeholder: "Select a date", class: 'rounded-md border shadow', id: 'date', data_controller: 'input')
                end
              end
              PopoverContent do
                Calendar(input_id: '#date')
              end
            end
          end
        RUBY
      end

      render Docs::ComponentsTable.new(component_references(component, Docs::VisualCodeExample.collected_code), component_files(component))
    end
  end
end
