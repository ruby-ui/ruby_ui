# frozen_string_literal: true

require "test_helper"

class RubyUI::DataTableSortHeadTest < ComponentTest
  def test_renders_th_with_sort_link_cycling_nil_to_asc
    output = phlex { RubyUI.DataTableSortHead(column_key: :name, label: "Name", path: "/x", query: {}) }
    assert_match(/<th/, output)
    assert_match(/href="\/x\?(sort=name&(amp;)?direction=asc|direction=asc&(amp;)?sort=name)"/, output)
    assert_match(/Name/, output)
  end

  def test_current_asc_next_href_is_desc
    output = phlex { RubyUI.DataTableSortHead(column_key: :name, label: "Name", sort: "name", direction: "asc", path: "/x", query: {}) }
    assert_match(/direction=desc/, output)
  end

  def test_current_desc_next_href_clears_sort
    output = phlex { RubyUI.DataTableSortHead(column_key: :name, label: "Name", sort: "name", direction: "desc", path: "/x", query: {}) }
    assert_match(/href="\/x"/, output)
  end

  def test_preserves_other_query_params
    output = phlex { RubyUI.DataTableSortHead(column_key: :name, label: "Name", path: "/x", query: {"search" => "alice"}) }
    assert_match(/search=alice/, output)
  end

  def test_renames_sort_and_direction_params
    output = phlex { RubyUI.DataTableSortHead(column_key: :name, label: "Name", sort_param: "sort_by", direction_param: "sort_dir", path: "/x", query: {}) }
    assert_match(/sort_by=name/, output)
    assert_match(/sort_dir=asc/, output)
  end

  def test_custom_page_param_is_dropped_from_next_href_when_sorting
    output = phlex { RubyUI.DataTableSortHead(column_key: :name, label: "Name", page_param: "p", path: "/x", query: {"p" => "3", "search" => "bob"}) }
    refute_match(/[?&]p=/, output)
    assert_match(/search=bob/, output)
  end
end
