# frozen_string_literal: true

class Docs::DatePickerView < ApplicationView
  def initialize
    @premium = true
  end

  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Date Picker", description: "A date picker component with input.", premium: @premium)

      render PhlexUI::Typography::H2.new { "Usage" }

      render Docs::VisualCodeExample.new(title: "Single Date", context: self, premium: @premium) do
        <<~RUBY
          div(class: 'space-y-4 w-[260px]') do
            render PhlexUI::Popover.new(options: { trigger: 'focusin' }) do
              render PhlexUI::Popover::Trigger.new(class: 'w-full') do
                div(class: 'grid w-full max-w-sm items-center gap-1.5') do
                  render PhlexUI::Label.new(for: "date") { "Select a date" }
                  render PhlexUI::Input.new(type: 'string', placeholder: "Select a date", class: 'rounded-md border shadow', id: 'date', data_controller: 'input')
                end
              end
              render PhlexUI::Popover::Content.new do
                render PhlexUI::Calendar.new(input_id: '#date')
              end
            end
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
      Docs::ComponentStruct.new(name: "PopoverController", source: "https://github.com/PhlexUI/phlex_ui_stimulus/blob/main/controllers/popover_controller.js", built_using: :stimulus),
      Docs::ComponentStruct.new(name: "PhlexUI::Calendar", source: "https://github.com/PhlexUI/phlex_ui_pro/blob/main/lib/phlex_ui_pro/calendar.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::Calendar::Body", source: "https://github.com/PhlexUI/phlex_ui_pro/blob/main/lib/phlex_ui_pro/calendar/body.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::Calendar::Days", source: "https://github.com/PhlexUI/phlex_ui_pro/blob/main/lib/phlex_ui_pro/calendar/days.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::Calendar::Header", source: "https://github.com/PhlexUI/phlex_ui_pro/blob/main/lib/phlex_ui_pro/calendar/header.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::Calendar::Next", source: "https://github.com/PhlexUI/phlex_ui_pro/blob/main/lib/phlex_ui_pro/calendar/next.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::Calendar::Prev", source: "https://github.com/PhlexUI/phlex_ui_pro/blob/main/lib/phlex_ui_pro/calendar/prev.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::Calendar::Title", source: "https://github.com/PhlexUI/phlex_ui_pro/blob/main/lib/phlex_ui_pro/calendar/title.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::Calendar::Weekdays", source: "https://github.com/PhlexUI/phlex_ui_pro/blob/main/lib/phlex_ui_pro/calendar/weekdays.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::Popover", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/popover.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::Popover::Trigger", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/popover/trigger.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::Popover::Content", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/popover/content.rb", built_using: :phlex)
    ]
  end
end
