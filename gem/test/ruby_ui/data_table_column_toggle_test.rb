# frozen_string_literal: true

require "test_helper"

class RubyUI::DataTableColumnToggleTest < ComponentTest
  def test_renders_dropdown_with_checkbox_per_column
    output = phlex do
      RubyUI.DataTableColumnToggle(columns: [
        {key: :email, label: "Email"},
        {key: :salary, label: "Salary"}
      ])
    end
    assert_match(/Columns/, output)
    assert_match(/data-controller="[^"]*ruby-ui--data-table-column-visibility/, output)
    assert_match(/data-column-key="email"/, output)
    assert_match(/data-column-key="salary"/, output)
    assert_match(/Email/, output)
    assert_match(/Salary/, output)
  end
end
