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

  def test_renders_a_custom_trigger_label
    output = phlex do
      RubyUI.DataTableColumnToggle(label: "Colunas", columns: [
        {key: :email, label: "Email"}
      ])
    end
    assert_match(/Colunas/, output)
  end

  def test_column_can_start_hidden
    output = phlex do
      RubyUI.DataTableColumnToggle(columns: [
        {key: :email, label: "Email"},
        {key: :salary, label: "Salary", visible: false}
      ])
    end
    # only the visible column renders the `checked` boolean attribute on its checkbox
    assert_equal 1, output.scan(/\bchecked(?:\s|>)/).length
  end

  def test_trigger_icons_carry_data_icon
    output = phlex { RubyUI.DataTableColumnToggle(columns: [{key: :email, label: "Email"}]) }
    assert_match(/<svg[^>]*data-icon="inline-start"/, output)
    assert_match(/<svg[^>]*data-icon="inline-end"/, output)
  end
end
