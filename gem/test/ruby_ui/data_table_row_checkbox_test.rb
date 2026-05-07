# frozen_string_literal: true

require "test_helper"

class RubyUI::DataTableRowCheckboxTest < ComponentTest
  def test_renders_checkbox_input_with_name_and_value
    output = phlex { RubyUI.DataTableRowCheckbox(value: 42) }
    assert_match(/<input[^>]*type="checkbox"/, output)
    assert_match(/name="ids\[\]"/, output)
    assert_match(/value="42"/, output)
  end

  def test_accepts_custom_name
    output = phlex { RubyUI.DataTableRowCheckbox(value: 1, name: "selected[]") }
    assert_match(/name="selected\[\]"/, output)
  end

  def test_carries_stimulus_target_and_action
    output = phlex { RubyUI.DataTableRowCheckbox(value: 1) }
    assert_match(/data-ruby-ui--data-table-target="rowCheckbox"/, output)
    assert_match(/data-action="[^"]*change->ruby-ui--data-table#toggleRow/, output)
  end

  def test_aria_label_contains_the_value
    output = phlex { RubyUI.DataTableRowCheckbox(value: 7) }
    assert_match(/aria-label="Select row 7"/, output)
  end

  def test_custom_aria_label_via_label_kwarg
    output = phlex { RubyUI.DataTableRowCheckbox(value: 1, label: "Select Alice Johnson") }
    assert_match(/aria-label="Select Alice Johnson"/, output)
  end
end
