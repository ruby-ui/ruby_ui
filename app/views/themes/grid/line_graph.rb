# frozen_string_literal: true

module Themes
  module Grid
    class LineGraph < ApplicationComponent
      def template
        render PhlexUI::Card.new(class: 'p-8 space-y-6') do
          div do
            render PhlexUI::Typography::Large.new { "Phlex Success" }
            render PhlexUI::Typography::Muted.new { "Number of stars on the Phlex Github repo" }
          end
          render PhlexUI::Chart.new(options: chart_options)
        end
      end

      private

      def chart_options
        {
          type: 'line',
          data: {
            labels: ['Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'],
            datasets: [{
              label: 'Github Stars',
              data: [40, 30, 79, 140, 290, 550],
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
          },
        }
      end
    end
  end
end