# frozen_string_literal: true

require "test_helper"

class RubyUI::DataTableBulkActionsTest < ComponentTest
  def test_starts_hidden_with_bulk_actions_target_and_renders_children
    output = erb(%(<%= render RubyUI::DataTableBulkActions.new do %>BUTTONS<% end %>))
    assert_match(/class="[^"]*hidden[^"]*"/, output)
    assert_match(/data-ruby-ui--data-table-target="bulkActions"/, output)
    assert_match(/BUTTONS/, output)
  end
end
