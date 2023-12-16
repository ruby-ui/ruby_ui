module Themes
  module Grid
    class CreateEvent < ApplicationComponent      
      def template
        render PhlexUI::Card.new(class: 'p-8 space-y-4') do
          div do
            render PhlexUI::Typography::Large.new { "Create an Event" }
            render PhlexUI::Typography::Muted.new { "Enter your event details below" }
          end
          event_form
        end
      end

      private

      def event_form
        render PhlexUI::Form.new(class: 'w-full') do
          render PhlexUI::Form::Spacer.new do
            render PhlexUI::Form::Item.new do
              render PhlexUI::Label.new(for: "name") { "Name" }
              render PhlexUI::Input.new(type: "string", value: "RuSki conf. Japan", id: "name")
            end
            render PhlexUI::Form::Item.new do
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
            render PhlexUI::Button.new(type: "submit", class: 'w-full') { "Create Event" }
          end
        end
      end
    end
  end
end