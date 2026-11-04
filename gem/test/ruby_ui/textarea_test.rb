# frozen_string_literal: true

require "test_helper"

class RubyUI::TextareaTest < ComponentTest
  def test_render_with_all_items
    output = phlex do
      RubyUI.Textarea(rows: 4, placeholder: "Comment")
    end

    assert_match(/Comment/, output)
  end

  def test_render_with_value
    output = phlex do
      RubyUI.Textarea { "Value" }
    end

    assert_match(/Value/, output)
  end

  def test_omits_rows_when_not_given
    output = phlex { RubyUI.Textarea }

    refute_match(/rows=/, output)
    assert_match(/field-sizing-content/, output)
  end

  def test_renders_given_rows
    output = phlex { RubyUI.Textarea(rows: 6) }

    assert_match(/rows="6"/, output)
    assert_match(/field-sizing-fixed/, output)
    refute_match(/field-sizing-content/, output)
  end

  def test_renders_data_slot
    output = phlex { RubyUI.Textarea }

    assert_match(/data-slot="textarea"/, output)
  end

  def test_caller_slot_replaces_default
    output = phlex { RubyUI.Textarea(data: {slot: "input-group-control"}) }

    assert_equal ["input-group-control"], output.scan(/data-slot="([^"]*)"/).flatten
  end

  def test_flat_data_slot_replaces_default
    output = phlex { RubyUI.Textarea(data_slot: "custom") }

    assert_equal ["custom"], output.scan(/data-slot="([^"]*)"/).flatten
  end

  def test_data_bang_override
    assert_equal ["custom"], phlex { RubyUI.Textarea(data!: {slot: "custom"}) }.scan(/data-slot="([^"]*)"/).flatten
    assert_empty phlex { RubyUI.Textarea(data!: nil) }.scan("data-slot=")
  end

  def test_keeps_form_field_wiring
    output = phlex { RubyUI.Textarea }

    assert_match(/data-ruby-ui--form-field-target="input"/, output)
  end

  def test_has_no_aria_disabled_styling
    refute_match(/aria-disabled:/, phlex { RubyUI.Textarea })
  end
end
