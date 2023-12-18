# frozen_string_literal: true

module Themes
  module Grid
    class Chart < ApplicationComponent
      def template
        render PhlexUI::Card.new(class: 'p-8 space-y-6') do
          div do
            render PhlexUI::Typography::Large.new { "Phlex Speed Tests" }
            render PhlexUI::Typography::Muted.new { "Render time for a simple page" }
          end
          render ::Chart.new(options: chart_options)
        end
      end

      private

      def chart_options
        {
          type: 'bar',
          data: {
            labels: ['Phlex', 'VC', 'ERB'],
            datasets: [{
              label: 'render time (ms)',
              data: [100, 520, 1200],
            }]
          },
          options: {
            indexAxis: 'y',
            scales: {
              y: {
                beginAtZero: true
              }
            },
          },
        }
      end
    end
  end
end