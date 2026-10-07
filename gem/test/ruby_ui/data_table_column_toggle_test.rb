# frozen_string_literal: true

require "test_helper"

class RubyUI::DataTableColumnToggleTest < ComponentTest
  def test_renders_dropdown_with_checkbox_per_column
    output = erb(%(<%= render RubyUI::DataTableColumnToggle.new(columns: [{key: :email, label: "Email"}, {key: :salary, label: "Salary"}]) %>))
    assert_match(/Columns/, output)
    assert_match(/data-controller="[^"]*ruby-ui--data-table-column-visibility/, output)
    assert_match(/data-column-key="email"/, output)
    assert_match(/data-column-key="salary"/, output)
    assert_match(/Email/, output)
    assert_match(/Salary/, output)
  end

  def test_renders_a_custom_trigger_label
    output = erb(%(<%= render RubyUI::DataTableColumnToggle.new(label: "Colunas", columns: [{key: :email, label: "Email"}]) %>))
    assert_match(/Colunas/, output)
  end

  def test_column_can_start_hidden
    output = erb(%(<%= render RubyUI::DataTableColumnToggle.new(columns: [{key: :email, label: "Email"}, {key: :salary, label: "Salary", visible: false}]) %>))
    # only the visible column renders the `checked` attribute — bare in Phlex,
    # checked="checked" through tag.attributes
    assert_equal 1, output.scan(/\bchecked(?:="checked")?(?:\s|>)/).length
  end
end
