# frozen_string_literal: true

module Components
  module Themes
    module Grid
      class LineGraph < Components::Base
        def view_template
          RubyUI::Card(class: "p-8 space-y-6") do
            div do
              Text(size: "4", weight: "semibold") { "Phlex Success" }
              Text(size: "2", class: "text-muted-foreground") { "Number of stars on the Phlex Github repo" }
            end
            RubyUI::Chart(options: chart_options)
          end
        end

        private

        def chart_options
          {
            type: "line",
            data: {
              labels: ["Feb", "Mar", "Apr", "May", "Jun", "Jul"],
              datasets: [{
                label: "Github Stars",
                data: [40, 30, 79, 140, 290, 550]
              }]
            },
            options: {
              scales: {
                y: {
                  beginAtZero: true
                }
              },
              plugins: {
                legend: {
                  display: false
                }
              }
            }
          }
        end
      end
    end
  end
end
