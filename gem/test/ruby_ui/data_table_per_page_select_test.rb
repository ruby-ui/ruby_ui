# frozen_string_literal: true

require "test_helper"

class RubyUI::DataTablePerPageSelectTest < ComponentTest
  def test_renders_get_form_with_select_and_options
    output = phlex { RubyUI.DataTablePerPageSelect(path: "/x", value: 25, options: [5, 10, 25, 50]) }
    assert_match(/<form[^>]*(method="get"[^>]*action="\/x"|action="\/x"[^>]*method="get")/, output)
    assert_match(/name="per_page"/, output)
    assert_match(/value="25"[^>]*selected|selected[^>]*value="25"/, output)
  end

  def test_submits_on_change_through_stimulus_without_inline_handler
    output = phlex { RubyUI.DataTablePerPageSelect(path: "/x") }
    select_tag = output[/<select(?:\s[^=\s]+="[^"]*")*/]
    assert_includes select_tag, 'data-controller="ruby-ui--data-table-per-page-select"'
    assert_match(/data-action="[^"]*change->ruby-ui--data-table-per-page-select#submit"/, select_tag)
    refute_match(/onchange/, output)
  end

  def test_targets_turbo_frame_from_the_form
    output = phlex { RubyUI.DataTablePerPageSelect(path: "/x", frame_id: "employees") }
    assert_match(/<form[^>]*data-turbo-frame="employees"/, output)
  end

  def test_keeps_caller_nested_data_on_the_form
    output = phlex { RubyUI.DataTablePerPageSelect(path: "/x", data: {controller: "filters", turbo_action: "advance"}) }
    form_tag = output[/<form[^>]*>/]
    assert_equal ['data-controller="filters"'], form_tag.scan(/data-controller="[^"]*"/)
    assert_match(/data-turbo-action="advance"/, form_tag)
  end

  def test_keeps_caller_flat_data_attributes_on_the_form
    output = phlex { RubyUI.DataTablePerPageSelect(path: "/x", data_controller: "filters") }
    form_tag = output[/<form[^>]*>/]
    assert_equal ['data-controller="filters"'], form_tag.scan(/data-controller="[^"]*"/)
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
