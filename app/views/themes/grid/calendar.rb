module Themes
  module Grid
    class Calendar < ApplicationComponent
      def view_template
        div(class: "space-y-4 w-full") do
          render PhlexUI::Input.new(type: "string", placeholder: "Select a date", class: "rounded-md border shadow", id: "formatted-date", data_controller: "input")
          render PhlexUI::Calendar.new(input_id: "#formatted-date", date_format: "PPPP", class: "rounded-md border shadow")
        end
      end
    end
  end
end
