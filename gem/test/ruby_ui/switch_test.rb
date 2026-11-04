# frozen_string_literal: true

require "test_helper"

class RubyUI::SwitchTest < ComponentTest
  def test_render_with_all_items
    output = phlex do
      RubyUI.Switch(name: "toggle")
    end

    assert_match(/toggle/, output)
  end

  def test_render_checked
    output = phlex do
      RubyUI.Switch(name: "toggle", checked: true)
    end

    assert_match(/<input[^>]*role="switch"[^>]*\schecked(?=[\s>])/, output)
  end

  def test_render_unchecked_has_no_checked_attribute
    output = phlex do
      RubyUI.Switch(name: "toggle")
    end

    refute_match(/\schecked(?=[\s>])/, output)
  end

  def test_focus_outline_survives_forced_colors
    output = phlex { RubyUI.Switch }

    assert_match(/\boutline-hidden\b/, output)
    refute_match(/\boutline-none\b/, output)
  end

  def test_renders_a_focusable_native_checkbox_with_role_switch
    output = phlex { RubyUI.Switch(id: "airplane", name: "airplane") }

    assert_match(/<input[^>]*type="checkbox"[^>]*role="switch"/, output)
    assert_match(/data-slot="switch"/, output)
    assert_match(/data-size="default"/, output)
    assert_match(/appearance-none/, output)
    refute_match(/<label/, output)
    refute_match(/class="(?:[^"]* )?hidden[ "]/, output)
  end

  def test_uses_vega_default_size
    output = phlex { RubyUI.Switch }

    assert_match(/data-\[size=default\]:h-\[18\.4px\]/, output)
    assert_match(/data-\[size=default\]:w-\[32px\]/, output)
    assert_match(/checked:before:translate-x-\[calc\(100%-2px\)\]/, output)
  end

  def test_small_size
    output = phlex { RubyUI.Switch(size: :sm) }

    assert_match(/data-size="sm"/, output)
  end

  def test_rejects_unknown_size
    assert_raises(ArgumentError) { RubyUI::Switch.new(size: :lg) }
  end

  def test_hidden_input_sends_the_unchecked_value_before_the_switch
    output = phlex { RubyUI.Switch(name: "user[admin]") }

    assert_match(/<input type="hidden" name="user\[admin\]" value="0" autocomplete="off"><input[^>]*value="1"/, output)
  end

  def test_include_hidden_false_skips_the_hidden_input
    output = phlex { RubyUI.Switch(name: "toggle", include_hidden: false) }

    refute_match(/type="hidden"/, output)
  end

  def test_custom_checked_and_unchecked_values
    output = phlex { RubyUI.Switch(name: "plan", checked_value: "on", unchecked_value: "off") }

    assert_match(/type="hidden" name="plan" value="off"/, output)
    assert_match(/role="switch"[^>]*value="on"|value="on"[^>]*role="switch"/, output)
  end

  def test_disabled_also_disables_the_hidden_input
    output = phlex { RubyUI.Switch(name: "toggle", disabled: true) }

    assert_match(/type="hidden" name="toggle" value="0" disabled/, output)
  end

  def test_aria_invalid_lands_on_the_switch
    output = phlex { RubyUI.Switch(aria: {invalid: "true"}) }

    assert_match(/<input[^>]*role="switch"[^>]*aria-invalid="true"|<input[^>]*aria-invalid="true"[^>]*role="switch"/, output)
  end
end
