# frozen_string_literal: true

module RBUI
  class CalendarPreview < Lookbook::Preview
    def default
      render(TestView.new) do
        div(class: "space-y-4") do
          Input(type: "string", placeholder: "Select a date", class: "rounded-md border shadow", id: "date", data_controller: "input")
          Calendar(input_id: "#date", class: "rounded-md border shadow")
        end
      end
    end
  end
end
