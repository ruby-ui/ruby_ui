# frozen_string_literal: true

require "test_helper"

class RubyUI::DataTablePaginationTest < ComponentTest
  def test_accepts_manual_keyword_shortcut
    output = phlex { RubyUI.DataTablePagination(page: 2, per_page: 10, total_count: 25, path: "/x", query: {}) }
    assert_match(/href="\/x\?page=1"/, output)  # Previous
    assert_match(/href="\/x\?page=3"/, output)  # Next
  end

  def test_accepts_pagy_keyword_shortcut_duck_typed_double
    pagy_double = Data.define(:page, :pages, :count, :items).new(page: 1, pages: 2, count: 15, items: 10)
    output = phlex { RubyUI.DataTablePagination(pagy: pagy_double, path: "/x", query: {}) }
    assert_match(/href="\/x\?page=2"/, output)
  end

  def test_with_accepts_custom_adapter
    custom = Data.define(:current_page, :total_pages, :total_count, :per_page).new(1, 3, 20, 10)
    output = phlex { RubyUI.DataTablePagination(with: custom, path: "/x", query: {}) }
    assert_match(/href="\/x\?page=2"/, output)
  end

  def test_renames_page_param
    output = phlex { RubyUI.DataTablePagination(page: 1, per_page: 10, total_count: 30, path: "/x", query: {}, page_param: "p") }
    assert_match(/p=2/, output)
  end

  def test_raises_when_no_adapter_and_no_manual_args
    assert_raises(ArgumentError) { RubyUI::DataTablePagination.new(path: "/x", query: {}) }
  end

  def test_window_kwarg_widens_numbered_page_range
    out_narrow = phlex { RubyUI.DataTablePagination(page: 10, per_page: 1, total_count: 20, path: "/x", query: {}, window: 1) }
    out_wide = phlex { RubyUI.DataTablePagination(page: 10, per_page: 1, total_count: 20, path: "/x", query: {}, window: 2) }
    refute_match(/page=8/, out_narrow)
    assert_match(/page=8/, out_wide)
  end
end
