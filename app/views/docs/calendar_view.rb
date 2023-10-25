# frozen_string_literal: true

class Docs::CalendarView < ApplicationView
  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      div(class: 'space-y-2') do
        render Docs::PremiumBadge.new
        render Typography::H1.new { "Calendar" }
        render Typography::P.new { "A date field component that allows users to enter and edit date." }
      end

      render Docs::VisualCodeExample.new(title: 'Connect to input', locked: true) do
        div(class: 'space-y-4') do
          render Input.new(type: 'string', placeholder: "Select a date", class: 'rounded-md border shadow', id: 'date', data_controller: 'input')
          render Calendar.new(class: 'rounded-md border shadow', data_calendar_input_outlet: '#date')
        end
      end

      render Docs::VisualCodeExample.new(title: 'Format date', description: 'Format dates with date-fns', locked: true) do
        div(class: 'space-y-4') do
          render Input.new(type: 'string', placeholder: "Select a date", class: 'rounded-md border shadow', id: 'formatted-date', data_controller: 'input')
          render Calendar.new(class: 'rounded-md border shadow', data_calendar_input_outlet: '#formatted-date', data_calendar_format_value: 'PPPP')
        end
      end

      render Docs::InstallationInstructionsComingSoon.new
    end
  end

  def info_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      fill: "none",
      viewbox: "0 0 24 24",
      stroke_width: "1.5",
      stroke: "currentColor",
      class: "w-4 h-4"
    ) do |s|
      s.path(
        stroke_linecap: "round",
        stroke_linejoin: "round",
        d:
          "M11.25 11.25l.041-.02a.75.75 0 011.063.852l-.708 2.836a.75.75 0 001.063.853l.041-.021M21 12a9 9 0 11-18 0 9 9 0 0118 0zm-9-3.75h.008v.008H12V8.25z"
      )
    end
  end
end
