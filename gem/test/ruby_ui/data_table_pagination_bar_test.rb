# frozen_string_literal: true

require "test_helper"

class RubyUI::DataTablePaginationBarTest < ComponentTest
  def test_renders_flex_justify_between_layout_and_children
    output = erb(%(<%= render RubyUI::DataTablePaginationBar.new do %>INNER<% end %>))
    assert_match(/class="[^"]*flex[^"]*"/, output)
    assert_match(/class="[^"]*justify-between[^"]*"/, output)
    assert_match(/INNER/, output)
  end
end
