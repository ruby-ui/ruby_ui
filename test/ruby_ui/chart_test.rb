# frozen_string_literal: true

require "test_helper"

class RubyUI::ChartTest < Minitest::Test
  include Phlex::Testing::ViewHelper

  def test_render_with_all_items
    output = phlex_context do
      options = {
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

      RubyUI.Chart(options: options)
    end

    assert_match(/Phlex/, output)
  end
end
