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
end
