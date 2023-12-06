# frozen_string_literal: true

class Docs::CalendarView < ApplicationView
  def initialize
    @premium = true
  end

  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Calendar", description: "A date field component that allows users to enter and edit date.", premium: @premium)

      render PhlexUI::Typography::H2.new { "Usage" }

      render Docs::VisualCodeExample.new(title: 'Connect to input', context: self, premium: @premium) do
        <<~RUBY
          div(class: 'space-y-4') do
            render PhlexUI::Input.new(type: 'string', placeholder: "Select a date", class: 'rounded-md border shadow', id: 'date', data_controller: 'input')
            render PhlexUI::Calendar.new(input_id: '#date', class: 'rounded-md border shadow')
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: 'Format date', description: 'Format dates with date-fns', context: self, premium: @premium) do
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
      Docs::ComponentStruct.new("PhlexUI::Calendar", "https://github.com/PhlexUI/phlex_ui_pro/blob/main/lib/phlex_ui_pro/calendar.rb"),
      Docs::ComponentStruct.new("PhlexUI::Calendar::Body", "https://github.com/PhlexUI/phlex_ui_pro/blob/main/lib/phlex_ui_pro/calendar/body.rb"),
      Docs::ComponentStruct.new("PhlexUI::Calendar::Days", "https://github.com/PhlexUI/phlex_ui_pro/blob/main/lib/phlex_ui_pro/calendar/days.rb"),
      Docs::ComponentStruct.new("PhlexUI::Calendar::Header", "https://github.com/PhlexUI/phlex_ui_pro/blob/main/lib/phlex_ui_pro/calendar/header.rb"),
      Docs::ComponentStruct.new("PhlexUI::Calendar::Next", "https://github.com/PhlexUI/phlex_ui_pro/blob/main/lib/phlex_ui_pro/calendar/next.rb"),
      Docs::ComponentStruct.new("PhlexUI::Calendar::Prev", "https://github.com/PhlexUI/phlex_ui_pro/blob/main/lib/phlex_ui_pro/calendar/prev.rb"),
      Docs::ComponentStruct.new("PhlexUI::Calendar::Title", "https://github.com/PhlexUI/phlex_ui_pro/blob/main/lib/phlex_ui_pro/calendar/title.rb"),
      Docs::ComponentStruct.new("PhlexUI::Calendar::Weekdays", "https://github.com/PhlexUI/phlex_ui_pro/blob/main/lib/phlex_ui_pro/calendar/weekdays.rb"),
    ]
  end
end
