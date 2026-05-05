# frozen_string_literal: true

require "test_helper"
require "ruby_ui/data_table/data_table_manual_adapter"

class RubyUI::DataTableManualAdapterTest < ComponentTest
  def test_computes_total_pages_from_total_count_and_per_page
    adapter = RubyUI::DataTableManualAdapter.new(page: 2, per_page: 10, total_count: 25)
    assert_equal 2, adapter.current_page
    assert_equal 10, adapter.per_page
    assert_equal 25, adapter.total_count
    assert_equal 3, adapter.total_pages
  end

  def test_total_pages_is_at_least_1_for_empty_total
    adapter = RubyUI::DataTableManualAdapter.new(page: 1, per_page: 10, total_count: 0)
    assert_equal 1, adapter.total_pages
  end

  def test_coerces_integer_inputs
    adapter = RubyUI::DataTableManualAdapter.new(page: "3", per_page: "5", total_count: "12")
    assert_equal 3, adapter.current_page
    assert_equal 3, adapter.total_pages
  end
end
