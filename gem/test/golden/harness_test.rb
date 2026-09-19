# frozen_string_literal: true

require "test_helper"
require "golden/harness"

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
