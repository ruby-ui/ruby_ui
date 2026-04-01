# frozen_string_literal: true

require 'test_helper'

module RubyUI
  class ChartTest < ComponentTest
    def test_render_with_all_items
      output = phlex do
        options = {
          type: 'bar',
          data: {
            labels: %w[Phlex VC ERB],
            datasets: [{
              label: 'render time (ms)',
              data: [100, 520, 1200]
            }]
          },
          options: {
            indexAxis: 'y',
            scales: {
              y: {
                beginAtZero: true
              }
            }
          }
        }

        RubyUI.Chart(options:)
      end

      assert_match(/Phlex/, output)
    end
  end
end
