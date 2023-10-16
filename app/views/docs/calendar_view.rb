# frozen_string_literal: true

class Docs::CalendarView < ApplicationView
  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-8") do
      div(class: 'space-y-2') do
        render Typography::H1.new { "Calendar" }
        render Typography::P.new { "A date field component that allows users to enter and edit date." }
      end

      render Docs::VisualCodeExample.new do
        render Calendar.new(class: 'rounded-md border shadow')
      end
    end
  end
end
