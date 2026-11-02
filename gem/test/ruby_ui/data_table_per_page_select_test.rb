# frozen_string_literal: true

require "test_helper"

class RubyUI::DataTablePerPageSelectTest < ComponentTest
  def test_renders_get_form_with_select_and_options
    output = phlex { RubyUI.DataTablePerPageSelect(path: "/x", value: 25, options: [5, 10, 25, 50]) }
    assert_match(/<form[^>]*(method="get"[^>]*action="\/x"|action="\/x"[^>]*method="get")/, output)
    assert_match(/name="per_page"/, output)
    assert_match(/value="25"[^>]*selected|selected[^>]*value="25"/, output)
    assert_match(/onchange="this\.form\.requestSubmit\(\)"/, output)
  end

  def test_renames_param_via_name
    output = phlex { RubyUI.DataTablePerPageSelect(path: "/x", name: "size") }
    assert_match(/name="size"/, output)
  end

  def test_includes_given_options
    output = phlex { RubyUI.DataTablePerPageSelect(path: "/x", options: [5, 10, 25]) }
    assert_match(/<option[^>]*value="5"/, output)
    assert_match(/<option[^>]*value="10"/, output)
    assert_match(/<option[^>]*value="25"/, output)
  end

  def test_labels_the_select
    output = phlex { RubyUI.DataTablePerPageSelect(path: "/x") }
    id = output[/<select [^<]*id="([^"]+)"/, 1]
    refute_nil id
    assert_match(/<label for="#{id}"[^>]*>Rows per page<\/label>/, output)
  end

  def test_default_ids_are_unique_per_instance
    first = phlex { RubyUI.DataTablePerPageSelect(path: "/a") }[/<select [^<]*id="([^"]+)"/, 1]
    second = phlex { RubyUI.DataTablePerPageSelect(path: "/b") }[/<select [^<]*id="([^"]+)"/, 1]
    refute_equal first, second
  end

  def test_custom_label_and_id
    output = phlex { RubyUI.DataTablePerPageSelect(path: "/x", label: "Por página", id: "pp") }
    assert_match(/<label for="pp"[^>]*>Por página<\/label>/, output)
    assert_match(/<select [^<]*id="pp"/, output)
  end

  def test_preserved_params_emit_hidden_inputs_skipping_blank_and_own_name
    output = phlex { RubyUI.DataTablePerPageSelect(path: "/x", preserved_params: {search: "ali", sort: "name", direction: "", per_page: "25"}) }
    assert_match(/<input type="hidden" name="search" value="ali"/, output)
    assert_match(/<input type="hidden" name="sort" value="name"/, output)
    refute_match(/name="direction"/, output)
    refute_match(/<input type="hidden" name="per_page"/, output)
  end
end
