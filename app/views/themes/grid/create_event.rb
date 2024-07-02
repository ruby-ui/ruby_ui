# frozen_string_literal: true

module Themes
  module Grid
    class CreateEvent < ApplicationComponent
      def view_template
        Card(class: "p-8 space-y-4") do
          div do
            TypographyLarge { "Create an Event" }
            TypographyMuted { "Enter your event details below" }
          end
          event_form
        end
      end

      private

      def event_form
        Form(class: "w-full") do
          FormSpacer do
            FormItem do
              Label(for: "name") { "Name" }
              Input(type: "string", value: "RuSki conf. Japan", id: "name")
            end
            FormItem do
              Popover(options: {trigger: "focusin"}) do
                PopoverTrigger(class: "w-full") do
                  div(class: "grid w-full max-w-sm items-center gap-1.5") do
                    Label(for: "date") { "Select a date" }
                    Input(type: "string", placeholder: "Select a date", class: "rounded-md border shadow", id: "date", data_controller: "input")
                  end
                end
                PopoverContent do
                  Calendar(input_id: "#date")
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
