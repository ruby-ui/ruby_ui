# frozen_string_literal: true

require "test_helper"

class RubyUI::DataTablePerPageSelectTest < ComponentTest
  ATTRS = %q{(?:\s[^\s=>]+(?:="[^"]*")?)*}

  def test_renders_get_form_with_select_and_value
    output = phlex { RubyUI.DataTablePerPageSelect(path: "/x", value: 25, options: [5, 10, 25, 50]) }
    assert_match(/<form#{ATTRS}\s(method="get"#{ATTRS}\saction="\/x"|action="\/x"#{ATTRS}\smethod="get")/o, output)
    assert_match(/<input#{ATTRS}\sname="per_page" value="25"/o, output)
    assert_match(/data-slot="select-value"#{ATTRS}>25<\/span>/o, output)
  end

  def test_matches_shadcn_block_parts
    output = phlex { RubyUI.DataTablePerPageSelect(path: "/x") }
    trigger = output[/<button#{ATTRS}\sdata-slot="select-trigger"#{ATTRS}>/o]
    assert_includes trigger, 'data-size="sm"'
    assert_match(/class="[^"]*\bw-20\b/, trigger)
    refute_match(/\bw-fit\b/, trigger)
    assert_match(/data-slot="select-content"#{ATTRS}\sdata-side="top"/o, output)
    refute_match(/<select\b/, output)
  end

  def test_submits_on_change_through_stimulus_without_inline_handler
    output = phlex { RubyUI.DataTablePerPageSelect(path: "/x") }
    input_tag = output[/<input#{ATTRS}\sname="per_page"#{ATTRS}>/o]
    assert_includes input_tag, 'data-controller="ruby-ui--data-table-per-page-select"'
    assert_match(/data-action="[^"]*change->ruby-ui--data-table-per-page-select#submit"/, input_tag)
    refute_match(/onchange/, output)
  end

  def test_targets_turbo_frame_from_the_form
    output = phlex { RubyUI.DataTablePerPageSelect(path: "/x", frame_id: "employees") }
    assert_match(/<form#{ATTRS}\sdata-turbo-frame="employees"/o, output)
  end

  def test_keeps_caller_nested_data_on_the_form
    output = phlex { RubyUI.DataTablePerPageSelect(path: "/x", data: {controller: "filters", turbo_action: "advance"}) }
    form_tag = output[/<form#{ATTRS}>/o]
    assert_equal ['data-controller="filters"'], form_tag.scan(/data-controller="[^"]*"/)
    assert_match(/data-turbo-action="advance"/, form_tag)
  end

  def test_keeps_caller_flat_data_attributes_on_the_form
    output = phlex { RubyUI.DataTablePerPageSelect(path: "/x", data_controller: "filters") }
    form_tag = output[/<form#{ATTRS}>/o]
    assert_equal ['data-controller="filters"'], form_tag.scan(/data-controller="[^"]*"/)
  end

  def test_renames_param_via_name
    output = phlex { RubyUI.DataTablePerPageSelect(path: "/x", name: "size") }
    assert_match(/<input#{ATTRS}\sname="size"/o, output)
  end

  def test_includes_given_options
    output = phlex { RubyUI.DataTablePerPageSelect(path: "/x", options: [5, 10, 25]) }
    assert_equal %w[5 10 25], output.scan(/role="option"#{ATTRS}\sdata-value="([^"]+)"/o).flatten
  end

  def test_labels_the_trigger
    output = phlex { RubyUI.DataTablePerPageSelect(path: "/x") }
    id = output[/<button#{ATTRS}\sid="([^"]+)"/o, 1]
    refute_nil id
    assert_match(/<label for="#{id}"#{ATTRS}>Rows per page<\/label>/, output)
  end

  def test_default_ids_are_unique_per_instance
    first = phlex { RubyUI.DataTablePerPageSelect(path: "/a") }[/<button#{ATTRS}\sid="([^"]+)"/o, 1]
    second = phlex { RubyUI.DataTablePerPageSelect(path: "/b") }[/<button#{ATTRS}\sid="([^"]+)"/o, 1]
    refute_nil first
    refute_equal first, second
  end

  def test_custom_label_and_id
    output = phlex { RubyUI.DataTablePerPageSelect(path: "/x", label: "Por página", id: "pp") }
    assert_match(/<label for="pp"#{ATTRS}>Por página<\/label>/o, output)
    assert_match(/<button#{ATTRS}\sid="pp"/o, output)
  end

  def test_preserved_params_emit_hidden_inputs_skipping_blank_and_own_name
    output = phlex { RubyUI.DataTablePerPageSelect(path: "/x", preserved_params: {search: "ali", sort: "name", direction: "", per_page: "25"}) }
    assert_match(/<input type="hidden" name="search" value="ali"/, output)
    assert_match(/<input type="hidden" name="sort" value="name"/, output)
    refute_match(/name="direction"/, output)
    refute_match(/<input type="hidden" name="per_page"/, output)
  end
end
