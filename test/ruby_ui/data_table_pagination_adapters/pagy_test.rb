# frozen_string_literal: true

require "test_helper"
require "ruby_ui/data_table_pagination_adapters/pagy"

class RubyUI::DataTablePaginationAdapters::PagyTest < ComponentTest
  PagyDouble = Data.define(:page, :pages, :count, :items)

  def test_reads_page_pages_count_items
    pagy = PagyDouble.new(page: 2, pages: 5, count: 47, items: 10)
    adapter = RubyUI::DataTablePaginationAdapters::Pagy.new(pagy)
    assert_equal 2, adapter.current_page
    assert_equal 5, adapter.total_pages
    assert_equal 47, adapter.total_count
    assert_equal 10, adapter.per_page
  end
end
