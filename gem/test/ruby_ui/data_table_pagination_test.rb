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

  def test_renders_page_x_of_y_and_named_first_previous_next_last_links
    output = phlex { RubyUI.DataTablePagination(page: 2, per_page: 10, total_count: 30, path: "/x", query: {}) }
    assert_match(/Page 2 of 3/, output)
    assert_match(/href="\/x\?page=1"[^>]*>.*Go to first page/m, output)
    assert_match(/Go to previous page/, output)
    assert_match(/href="\/x\?page=3"[^>]*>.*Go to next page/m, output)
    assert_match(/Go to last page/, output)
    refute_match(/aria-disabled="true"/, output)
  end

  def test_disables_first_and_previous_on_the_first_page
    output = phlex { RubyUI.DataTablePagination(page: 1, per_page: 10, total_count: 30, path: "/x", query: {}) }
    assert_equal 2, output.scan('aria-disabled="true"').length
    refute_match(/href="\/x\?page=0"/, output)
  end

  def test_custom_labels
    output = phlex { RubyUI.DataTablePagination(page: 1, per_page: 10, total_count: 30, path: "/x", query: {}, labels: {next: "Próxima página"}) }
    assert_match(/Próxima página/, output)
    assert_match(/Go to last page/, output)
  end

  def test_renders_nothing_for_a_single_page
    output = phlex { RubyUI.DataTablePagination(page: 1, per_page: 10, total_count: 5, path: "/x", query: {}) }
    assert_equal "", output.strip
  end
end
