# frozen_string_literal: true

require "test_helper"

class RubyUI::ChartTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::Chart.new.is_a?(Phlex::HTML)
  end

  def test_default_data_controller
    chart = RubyUI::Chart.new
    assert_equal "ruby-ui--chart", chart.attrs[:data_controller]
  end

  def test_options_serialized_to_json
    options = {type: "bar", data: {labels: ["A", "B"]}}
    chart = RubyUI::Chart.new(options: options)
    parsed = JSON.parse(chart.attrs[:data_ruby_ui__chart_options_value])
    assert_equal "bar", parsed["type"]
    assert_equal ["A", "B"], parsed["data"]["labels"]
  end

  def test_empty_options_default
    chart = RubyUI::Chart.new
    assert_equal "{}", chart.attrs[:data_ruby_ui__chart_options_value]
  end

  def test_user_attrs_pass_through
    chart = RubyUI::Chart.new(id: "my-chart", class: "w-full")
    assert_equal "my-chart", chart.attrs[:id]
    assert_includes chart.attrs[:class], "w-full"
  end
end
