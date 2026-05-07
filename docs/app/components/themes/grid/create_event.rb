# frozen_string_literal: true

module Components
  module Themes
    module Grid
      class CreateEvent < Components::Base
        def view_template
          RubyUI::Card(class: "p-8 space-y-4") do
            div do
              Text(size: "4", weight: "semibold") { "Create an Event" }
              Text(size: "2", class: "text-muted-foreground") { "Enter your event details below" }
            end
            event_form
          end
        end

        private

        def event_form
          Form(class: "w-full") do
            FormField do
              FormFieldLabel(for: "name") { "Name" }
              Input(type: "string", value: "RuSki conf. Japan", id: "name")
            end
            FormField do
              Popover(options: {trigger: "focusin"}) do
                PopoverTrigger(class: "w-full") do
                  div(class: "grid w-full max-w-sm items-center gap-1.5") do
                    FormFieldLabel(for: "date") { "Select a date" }
                    Input(type: "string", placeholder: "Select a date", class: "rounded-md border shadow", id: "date", data_controller: "input")
                  end
                end
                PopoverContent do
                  RubyUI::Calendar(input_id: "#date")
                end
              end
            end
            Button(type: "submit", class: "w-full") { "Create Event" }
          end
        end
      end
    end
  end
end
