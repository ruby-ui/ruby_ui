# frozen_string_literal: true

module Components
  module Themes
    module Grid
      class Chart < Components::Base
        def view_template
          RubyUI::Card(class: "p-8 space-y-6") do
            div do
              Text(size: "4", weight: "semibold") { "Phlex Speed Tests" }
              Text(size: "2", class: "text-muted-foreground") { "Render time for a simple page" }
            end
            RubyUI::Chart(options: chart_options)
          end
        end

        private

        def chart_options
          {
            type: "bar",
            data: {
              labels: ["Phlex", "VC", "ERB"],
              datasets: [{
                label: "render time (ms)",
                data: [100, 520, 1200]
              }]
            },
            options: {
              indexAxis: "y",
              scales: {
                y: {
                  beginAtZero: true
                }
              }
            }
          }
        end
      end
    end
  end
end
