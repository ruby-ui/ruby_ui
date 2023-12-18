# frozen_string_literal: true

module Themes
  module Grid
    class LineGraph < ApplicationComponent
      def template
        render PhlexUI::Card.new(class: 'p-8 space-y-6') do
          div do
            render PhlexUI::Typography::Large.new { "Phlex Github Stars" }
            render PhlexUI::Typography::Muted.new { "This is a chart of the stars on the Phlex Github repo" }
          end
          render ::Chart.new(options: chart_options)
        end
      end

      private

      def chart_options
        {
          type: 'line',
          data: {
            labels: ['Wk 1', 'Wk 2', 'Wk 3', 'Wk 4', 'Wk 5', 'Wk 6'],
            datasets: [{
              label: 'Github Stars',
              data: [30, 37, 97, 225, 445, 612],
            }]
          },
          options: {
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