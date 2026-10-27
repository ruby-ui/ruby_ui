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
    assert_match(/<form[^>]*data-controller="ruby-ui--data-table-per-page-select"/, output)
    assert_match(/<select[^>]*data-action="[^"]*change->ruby-ui--data-table-per-page-select#submit"/, output)
    refute_match(/onchange/, output)
  end

  def test_keeps_controller_alongside_turbo_frame
    output = phlex { RubyUI.DataTablePerPageSelect(path: "/x", frame_id: "employees") }
    assert_match(/data-turbo-frame="employees"/, output)
    assert_match(/data-controller="ruby-ui--data-table-per-page-select"/, output)
  end

  def test_keeps_controller_alongside_caller_data
    output = phlex { RubyUI.DataTablePerPageSelect(path: "/x", data: {controller: "filters", turbo_action: "advance"}) }
    assert_match(/data-controller="filters ruby-ui--data-table-per-page-select"/, output)
    assert_match(/data-turbo-action="advance"/, output)
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
