# frozen_string_literal: true

class Docs::CalendarView < ApplicationView
  def initialize
    @premium = true
  end

  def view_template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Calendar", description: "A date field component that allows users to enter and edit date.", premium: @premium)

      render PhlexUI::Typography::H2.new { "Usage" }

      render Docs::VisualCodeExample.new(title: "Connect to input", context: self, premium: @premium) do
        <<~RUBY
          div(class: 'space-y-4') do
            render PhlexUI::Input.new(type: 'string', placeholder: "Select a date", class: 'rounded-md border shadow', id: 'date', data_controller: 'input')
            render PhlexUI::Calendar.new(input_id: '#date', class: 'rounded-md border shadow')
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Format date", description: "Format dates with date-fns", context: self, premium: @premium) do
        <<~RUBY
          div(class: 'space-y-4') do
            render PhlexUI::Input.new(type: 'string', placeholder: "Select a date", class: 'rounded-md border shadow', id: 'formatted-date', data_controller: 'input')
            render PhlexUI::Calendar.new(input_id: '#formatted-date', date_format: 'PPPP', class: 'rounded-md border shadow')
          end
        RUBY
      end

      render Docs::ComponentsTable.new(components)
    end
  end

  private

  def components
    [
      Docs::ComponentStruct.new(name: "CalendarController", source: "https://github.com/PhlexUI/phlex_ui_stimulus_pro/blob/main/controllers/calendar_controller.js", built_using: :stimulus),
      Docs::ComponentStruct.new(name: "PhlexUI::Calendar", source: "https://github.com/PhlexUI/phlex_ui_pro/blob/main/lib/phlex_ui_pro/calendar.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::Calendar::Body", source: "https://github.com/PhlexUI/phlex_ui_pro/blob/main/lib/phlex_ui_pro/calendar/body.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::Calendar::Days", source: "https://github.com/PhlexUI/phlex_ui_pro/blob/main/lib/phlex_ui_pro/calendar/days.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::Calendar::Header", source: "https://github.com/PhlexUI/phlex_ui_pro/blob/main/lib/phlex_ui_pro/calendar/header.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::Calendar::Next", source: "https://github.com/PhlexUI/phlex_ui_pro/blob/main/lib/phlex_ui_pro/calendar/next.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::Calendar::Prev", source: "https://github.com/PhlexUI/phlex_ui_pro/blob/main/lib/phlex_ui_pro/calendar/prev.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::Calendar::Title", source: "https://github.com/PhlexUI/phlex_ui_pro/blob/main/lib/phlex_ui_pro/calendar/title.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::Calendar::Weekdays", source: "https://github.com/PhlexUI/phlex_ui_pro/blob/main/lib/phlex_ui_pro/calendar/weekdays.rb", built_using: :phlex)
    ]
  end
end
