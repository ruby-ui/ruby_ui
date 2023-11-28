# frozen_string_literal: true

class Docs::DatePickerView < ApplicationView
  def initialize
    @premium = true
  end

  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Date Picker", description: "A date picker component with input.", premium: @premium)

      render Docs::VisualCodeExample.new(title: 'Single Date', context: self, premium: @premium) do
        <<~RUBY
          div(class: 'space-y-4 w-[200px]') do
            render PhlexUI::Popover.new(options: { trigger: 'focusin' }) do
              render PhlexUI::Popover::Trigger.new do
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

      render Docs::InstallationInstructionsComingSoon.new
    end
  end
end
