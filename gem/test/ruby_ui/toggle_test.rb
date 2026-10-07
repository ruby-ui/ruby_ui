# frozen_string_literal: true

require "test_helper"

class RubyUI::ToggleTest < ComponentTest
  def test_renders_button_unpressed_by_default
    output = erb(%(<%= render RubyUI::Toggle.new do %>Bold<% end %>))
    assert_match(/<button[^>]*type="button"/, output)
    assert_match(/aria-pressed="false"/, output)
    assert_match(/data-state="off"/, output)
    assert_match(/Bold/, output)
  end

  def test_renders_pressed_when_pressed_true
    output = erb(%(<%= render RubyUI::Toggle.new(pressed: true) do %>Bold<% end %>))
    assert_match(/aria-pressed="true"/, output)
    assert_match(/data-state="on"/, output)
  end

  def test_renders_hidden_input_when_name_present
    output = erb(%(<%= render RubyUI::Toggle.new(name: "bold", value: "1") do %>Bold<% end %>))
    assert_match(/<input[^>]*type="hidden"[^>]*name="bold"/, output)
    assert_match(/value=""/, output)
  end

  def test_hidden_input_value_reflects_pressed
    output = erb(%(<%= render RubyUI::Toggle.new(name: "bold", value: "1", pressed: true) do %>Bold<% end %>))
    assert_match(/<input[^>]*name="bold"[^>]*value="1"/, output)
  end

  def test_no_hidden_input_when_name_absent
    output = erb(%(<%= render RubyUI::Toggle.new do %>Bold<% end %>))
    refute_match(/type="hidden"/, output)
  end

  def test_outline_variant_applies_border_class
    output = erb(%(<%= render RubyUI::Toggle.new(variant: :outline) do %>x<% end %>))
    assert_match(/border-input/, output)
  end

  def test_size_sm_applies_h8
    output = erb(%(<%= render RubyUI::Toggle.new(size: :sm) do %>x<% end %>))
    assert_match(/h-8/, output)
  end

  def test_size_lg_applies_h10
    output = erb(%(<%= render RubyUI::Toggle.new(size: :lg) do %>x<% end %>))
    assert_match(/h-10/, output)
  end

  def test_disabled_sets_attribute
    output = erb(%(<%= render RubyUI::Toggle.new(disabled: true) do %>x<% end %>))
    assert_match(/<button[^>]*disabled/, output)
  end

  def test_includes_stimulus_controller_and_action
    output = erb(%(<%= render RubyUI::Toggle.new do %>x<% end %>))
    assert_match(/data-controller="[^"]*ruby-ui--toggle/, output)
    assert_match(/data-action="[^"]*#{descriptor("click->ruby-ui--toggle#toggle")}/, output)
  end

  def test_includes_stimulus_values
    output = erb(%(<%= render RubyUI::Toggle.new(value: "x", unpressed_value: "y", pressed: true) do %>x<% end %>))
    assert_match(/data-ruby-ui--toggle-pressed-value="true"/, output)
    assert_match(/data-ruby-ui--toggle-value-value="x"/, output)
    assert_match(/data-ruby-ui--toggle-unpressed-value-value="y"/, output)
  end

  # 2.0: variant and size are coerced (spec decision B).
  def test_variant_and_size_accept_the_string_form
    assert_equal erb(%(<%= render RubyUI::Toggle.new(variant: :outline, size: :lg) do %>B<% end %>)),
      erb(%(<%= render RubyUI::Toggle.new(variant: "outline", size: "lg") do %>B<% end %>))
  end

  def test_an_unknown_variant_names_the_allowed_ones
    error = assert_raises(ArgumentError) { RubyUI::Toggle.new(variant: :ghost) }
    assert_match(/:default, :outline/, error.message)
  end

  def test_the_hidden_input_carries_the_unpressed_value_when_not_pressed
    output = erb(%(<%= render RubyUI::Toggle.new(name: "bold", value: "1", unpressed_value: "0") do %>B<% end %>))
    assert_match(/<input[^>]*type="hidden"[^>]*name="bold"[^>]*value="0"/, output)
  end
end
