# frozen_string_literal: true

require "test_helper"

class RubyUI::InputOtpTest < ComponentTest
  def test_render_wires_stimulus_controller_and_values
    output = phlex { RubyUI.InputOtp(length: 6, name: "otp") }

    assert_match(/data-controller="ruby-ui--input-otp"/, output)
    assert_match(/data-ruby-ui--input-otp-length-value="6"/, output)
    assert_match(/data-ruby-ui--input-otp-char-class-value="\[0-9\]"/, output)
  end

  def test_render_forwards_form_attrs_to_real_input
    output = phlex { RubyUI.InputOtp(length: 6, name: "otp", value: "123") }

    assert_match(/name="otp"/, output)
    assert_match(/value="123"/, output)
    assert_match(/maxlength="6"/, output)
    assert_match(/autocomplete="one-time-code"/, output)
  end

  def test_render_defaults_to_numeric_inputmode_and_digit_pattern
    output = phlex { RubyUI.InputOtp(length: 4, name: "otp") }

    assert_match(/inputmode="numeric"/, output)
    assert_match(/pattern="\^\(\?:\[0-9\]\)\{4\}\$"/, output)
  end

  def test_render_with_custom_pattern_uses_text_inputmode
    output = phlex { RubyUI.InputOtp(length: 4, name: "otp", pattern: "[0-9A-Za-z]") }

    assert_match(/inputmode="text"/, output)
    assert_match(/data-ruby-ui--input-otp-char-class-value="\[0-9A-Za-z\]"/, output)
    assert_match(/pattern="\^\(\?:\[0-9A-Za-z\]\)\{4\}\$"/, output)
  end

  def test_render_yields_block_content
    output = phlex { RubyUI.InputOtp(length: 1, name: "otp") { RubyUI.Badge { "marker" } } }

    assert_match(/marker/, output)
  end
end
