# frozen_string_literal: true

require "test_helper"

class RubyUI::DataTableSelectAllCheckboxTest < ComponentTest
  def test_carries_select_all_target_toggle_all_action_and_aria_label
    output = phlex { RubyUI.DataTableSelectAllCheckbox() }
    assert_match(/<input[^>]*type="checkbox"/, output)
    assert_match(/data-ruby-ui--data-table-target="selectAll"/, output)
    assert_match(/data-action="[^"]*change->ruby-ui--data-table#toggleAll/, output)
    assert_match(/aria-label="Select all"/, output)
  end
end
