# frozen_string_literal: true

class Docs::DatePickerView < ApplicationView
  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      div(class: 'space-y-2') do
        render Docs::PremiumBadge.new
        render Typography::H1.new { "Date Picker" }
        render Typography::P.new { "A date picker component with input." }
      end

      render Docs::VisualCodeExample.new(title: 'Single Date', locked: true) do
        div(class: 'space-y-4 w-[200px]') do
          render Popover.new(options: { trigger: 'focusin' }) do
            render PopoverTrigger.new do
              div(class: 'grid w-full max-w-sm items-center gap-1.5') do
                render Label.new(for: "date") { "Select a date" }
                render Input.new(type: 'string', placeholder: "Select a date", class: 'rounded-md border shadow', id: 'date', data_controller: 'input')
              end
            end
            render PopoverContent.new do
              render Calendar.new(data_calendar_input_outlet: '#date')
            end
          end
        end
      end

      render Docs::InstallationInstructionsComingSoon.new
    end
  end
end
