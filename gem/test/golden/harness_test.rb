# frozen_string_literal: true

require "test_helper"
require "golden/harness"
require "golden/catalog"
require "golden/scenarios"

class GoldenHarnessTest < Minitest::Test
  def test_records_a_class_when_it_renders_not_when_it_is_instantiated
    with_fresh_recording do
      Golden::Harness.render { RubyUI::Button.new(variant: :outline).attrs }

      refute_includes Golden::Harness.classes_rendered.keys, "RubyUI::Button",
        "an instantiated-but-unrendered component must not count as covered"

      Golden::Harness.render { RubyUI.Button { "x" } }

      assert_includes Golden::Harness.classes_rendered.keys, "RubyUI::Button"
    end
  end

  def test_rejects_a_non_numeric_range_without_materialising_it
    Golden::Harness.render do
      assert_raises(ArgumentError) { Golden::Harness.next_rand("a".."z") }
    end
  end

  def test_rejects_an_unbounded_range_before_materialising_it
    # An endless range cannot be turned into an Array at all: if the guard ran
    # after `to_a`, this would raise RangeError from Ruby, not our ArgumentError.
    Golden::Harness.render do
      error = assert_raises(ArgumentError) { Golden::Harness.next_rand(1..) }

      assert_match(/refusing to pin/, error.message)
    end
  end

  def test_rejects_a_numeric_range_over_the_pin_limit
    Golden::Harness.render do
      assert_raises(ArgumentError) { Golden::Harness.next_rand(1..(Golden::Harness::MAX_PINNED_RANGE + 1)) }
    end
  end

  def test_pins_rand_to_the_same_value_on_every_render
    # The property the snapshots rely on: a component's rand(50..89) yields the
    # same number on every scenario render, not merely a number in range.
    values = Array.new(2) do
      value = nil
      Golden::Harness.render { value = Golden::Harness.next_rand(50..89) }
      value
    end

    assert_equal values.first, values.last
    assert_includes 50..89, values.first
  end

  # ActionView instruments every render, and the first instrumentation on a
  # thread creates the Instrumenter, whose id is SecureRandom.hex(10). A fresh
  # thread reproduces "the first ERB render of the process": the pin must not
  # hand that call the counter's first value, or every generated id in that one
  # render is shifted by one and the scenario fails its own determinism check.
  def test_erb_lane_mints_the_same_ids_on_a_threads_first_render
    scenario = Golden::Catalog.scenarios.find { |candidate| candidate.slug == "tooltip/default" }
    first, second = Thread.new { Array.new(2) { Golden::Harness.render_erb(scenario) } }.value

    assert_equal second, first
    assert_includes first, 'id="tooltip00000001"'
  end

  private

  # The recording hash is process-wide and the golden scenarios fill it; swap
  # it out so this test sees only its own renders.
  def with_fresh_recording
    saved = Golden::Harness.classes_rendered
    Golden::Harness.instance_variable_set(:@classes_rendered, {})
    yield
  ensure
    Golden::Harness.instance_variable_set(:@classes_rendered, saved)
  end
end
