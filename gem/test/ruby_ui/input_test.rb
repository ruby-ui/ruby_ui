# frozen_string_literal: true

require "test_helper"

class RubyUI::InputTest < ComponentTest
  def test_render_with_all_items
    output = phlex do
      RubyUI.Input(type: "email", placeholder: "Email")
    end

    assert_match(/Email/, output)
  end

  def test_render_with_value
    output = phlex do
      RubyUI.Input(type: "email", value: "user@email.com")
    end

    assert_match(/user@email.com/, output)
  end

  def test_omits_type_when_not_given
    output = phlex { RubyUI.Input(placeholder: "Name") }

    refute_match(/type=/, output)
  end

  def test_renders_given_type
    output = phlex { RubyUI.Input(type: :password) }

    assert_match(/type="password"/, output)
  end

  def test_marks_disabled_with_data_disabled
    output = phlex { RubyUI.Input(disabled: true) }

    assert_match(/<input[^>]* data-disabled[ >]/, output)
  end

  def test_omits_data_disabled_when_enabled
    refute_match(/data-disabled/, phlex { RubyUI.Input })
    refute_match(/data-disabled/, phlex { RubyUI.Input(disabled: false) })
  end

  def test_renders_data_slot
    output = phlex { RubyUI.Input }

    assert_match(/data-slot="input"/, output)
  end

  def test_caller_slot_replaces_default
    output = phlex { RubyUI.Input(data: {slot: "input-group-control"}) }

    assert_equal ["input-group-control"], output.scan(/data-slot="([^"]*)"/).flatten
  end

  def test_flat_data_slot_replaces_default
    output = phlex { RubyUI.Input(data_slot: "custom") }

    assert_equal ["custom"], output.scan(/data-slot="([^"]*)"/).flatten
  end

  def test_data_bang_override
    assert_equal ["custom"], phlex { RubyUI.Input(data!: {slot: "custom"}) }.scan(/data-slot="([^"]*)"/).flatten
    assert_empty phlex { RubyUI.Input(data!: nil) }.scan("data-slot=")
  end

  def test_does_not_mutate_caller_data
    data = {slot: "custom"}.freeze

    output = phlex { RubyUI.Input(data!: data) }

    assert_match(/data-slot="custom"/, output)
  end

  def test_caller_slot_bang_inside_data
    output = phlex { RubyUI.Input(data: {slot!: "custom"}) }

    assert_equal ["custom"], output.scan(/data-slot="([^"]*)"/).flatten
  end
end
