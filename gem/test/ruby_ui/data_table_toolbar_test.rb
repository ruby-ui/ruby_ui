# frozen_string_literal: true

require "test_helper"

class RubyUI::DataTableToolbarTest < ComponentTest
  def test_renders_div_with_flex_layout_and_children
    output = phlex { RubyUI.DataTableToolbar { "INNER" } }
    assert_match(/<div[^>]*class="[^"]*flex[^"]*"/, output)
    assert_match(/INNER/, output)
  end

  def test_leaves_the_block_gap_above_the_table
    output = phlex { RubyUI.DataTableToolbar { "INNER" } }
    assert_match(/<div[^>]*class="[^"]*\bpb-2\b/, output)
  end
end
