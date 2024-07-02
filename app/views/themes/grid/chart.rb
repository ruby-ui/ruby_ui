# frozen_string_literal: true

module Themes
  module Grid
    class Chart < ApplicationComponent
      def view_template
        Card(class: "p-8 space-y-6") do
          div do
            TypographyLarge { "Phlex Speed Tests" }
            TypographyMuted { "Render time for a simple page" }
          end
          Chart(options: chart_options)
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
