# frozen_string_literal: true

require "test_helper"

class RubyUI::CheckboxTest < ComponentTest
  def test_render_with_all_items
    output = phlex do
      RubyUI.Checkbox(id: "terms")
    end

    assert_match(/terms/, output)
  end

  def test_renders_a_native_checkbox_with_data_slot
    output = phlex { RubyUI.Checkbox(id: "terms") }

    assert_match(/<input[^>]*type="checkbox"/, output)
    assert_match(/data-slot="checkbox"/, output)
    assert_match(/rounded-\[4px\]/, output)
    assert_match(/appearance-none/, output)
  end

  def test_has_no_controller_by_default
    output = phlex { RubyUI.Checkbox(id: "terms") }

    refute_match(/data-controller/, output)
    refute_match(/aria-readonly/, output)
    assert_match(/change->ruby-ui--form-field#onInput/, output)
  end

  def test_indeterminate_wires_the_controller
    output = phlex { RubyUI.Checkbox(indeterminate: true) }

    assert_match(/data-controller="ruby-ui--checkbox"/, output)
    assert_match(/data-ruby-ui--checkbox-indeterminate-value="true"/, output)
    assert_match(/click->ruby-ui--checkbox#guard/, output)
  end

  def test_readonly_sets_aria_readonly_and_the_controller
    output = phlex { RubyUI.Checkbox(readonly: true) }

    assert_match(/aria-readonly="true"/, output)
    assert_match(/data-ruby-ui--checkbox-readonly-value="true"/, output)
    refute_match(/\sreadonly(=|\s|>)/, output)
  end

  def test_unchecked_value_renders_a_hidden_input_first
    output = phlex { RubyUI.Checkbox(name: "user[admin]", value: "1", unchecked_value: "0") }

    hidden = output.index('type="hidden"')
    checkbox = output.index('type="checkbox"')
    assert hidden && checkbox && hidden < checkbox
    assert_match(/<input type="hidden" name="user\[admin\]" value="0"/, output)
  end

  def test_unchecked_value_copies_disabled
    output = phlex { RubyUI.Checkbox(name: "a", unchecked_value: "0", disabled: true) }

    assert_match(/<input type="hidden"[^>]*disabled/, output)
  end

  def test_unchecked_value_false_is_rendered
    output = phlex { RubyUI.Checkbox(name: "a", unchecked_value: false) }

    assert_match(/<input type="hidden" name="a" value="false"/, output)
    assert_raises(ArgumentError) { RubyUI::Checkbox.new(unchecked_value: false) }
  end

  def test_unchecked_value_requires_name
    assert_raises(ArgumentError) { RubyUI::Checkbox.new(unchecked_value: "0") }
  end
end
