# frozen_string_literal: true

module RBUI
  class DatePickerPreview < Lookbook::Preview
    # Default DatePicker
    # ---------------
    def default
      render(TestView.new) do
        div(class: "space-y-4 w-[260px]") do
          Popover(options: {trigger: "focusin"}) do
            PopoverTrigger(class: "w-full") do
              div(class: "grid w-full max-w-sm items-center gap-1.5") do
                label(for: "date") { "Select a date" }
                Input(type: "string", placeholder: "Select a date", class: "rounded-md border shadow", id: "date", data_controller: "input")
              end
            end
            PopoverContent do
              Calendar(input_id: "#date")
            end
          end
        end
      end
    end
  end
end
