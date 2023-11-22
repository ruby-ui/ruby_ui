# frozen_string_literal: true

class Docs::CalendarView < ApplicationView
  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      div(class: 'space-y-2') do
        render Docs::PremiumBadge.new
        render PhlexUI::Typography::H1.new { "Calendar" }
        render PhlexUI::Typography::P.new { "A date field component that allows users to enter and edit date." }
      end

      render Docs::VisualCodeExample.new(title: 'Connect to input', locked: true, context: self) do
        <<~RUBY
          div(class: 'space-y-4') do
            render PhlexUI::Input.new(type: 'string', placeholder: "Select a date", class: 'rounded-md border shadow', id: 'date', data_controller: 'input')
            render PhlexUI::Calendar.new(input_id: '#date', class: 'rounded-md border shadow')
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: 'Format date', description: 'Format dates with date-fns', locked: true, context: self) do
        <<~RUBY
          div(class: 'space-y-4') do
            render PhlexUI::Input.new(type: 'string', placeholder: "Select a date", class: 'rounded-md border shadow', id: 'formatted-date', data_controller: 'input')
            render PhlexUI::Calendar.new(input_id: '#formatted-date', date_format: 'PPPP', class: 'rounded-md border shadow')
          end
        RUBY
      end

      render Docs::InstallationInstructionsComingSoon.new
    end
  end
end
