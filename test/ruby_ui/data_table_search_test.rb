# frozen_string_literal: true

require "test_helper"

class RubyUI::DataTableSearchTest < ComponentTest
  def test_renders_get_form_with_search_input
    output = phlex { RubyUI.DataTableSearch(path: "/x", value: "alice", name: "search") }
    assert_match(/<form[^>]*method="get"[^>]*action="\/x"/, output)
    assert_match(/name="search"/, output)
    assert_match(/value="alice"/, output)
  end

  def test_renames_param_via_name
    output = phlex { RubyUI.DataTableSearch(path: "/x", name: "q") }
    assert_match(/name="q"/, output)
  end

  def test_emits_data_turbo_frame_when_frame_id_given
    output = phlex { RubyUI.DataTableSearch(path: "/x", frame_id: "employees") }
    assert_match(/data-turbo-frame="employees"/, output)
  end

  def test_emits_debounce_controller_and_delay_value_and_action_by_default
    output = phlex { RubyUI.DataTableSearch(path: "/x") }
    assert_match(/data-controller="ruby-ui--data-table-search"/, output)
    assert_match(/data-ruby-ui--data-table-search-delay-value="300"/, output)
    assert_match(/data-action="input->ruby-ui--data-table-search#submit"/, output)
  end

  def test_debounce_500_sets_custom_delay
    output = phlex { RubyUI.DataTableSearch(path: "/x", debounce: 500) }
    assert_match(/data-ruby-ui--data-table-search-delay-value="500"/, output)
  end

  def test_debounce_false_disables_auto_submit
    output = phlex { RubyUI.DataTableSearch(path: "/x", debounce: false) }
    refute_match(/data-controller="ruby-ui--data-table-search"/, output)
    refute_match(/data-ruby-ui--data-table-search-delay-value/, output)
  end

  def test_debounce_0_disables_auto_submit
    output = phlex { RubyUI.DataTableSearch(path: "/x", debounce: 0) }
    refute_match(/data-controller="ruby-ui--data-table-search"/, output)
  end

  def test_preserved_params_emits_hidden_inputs_for_each_key
    output = phlex do
      RubyUI.DataTableSearch(path: "/x", name: "search",
        preserved_params: {"sort" => "name", "direction" => "asc", "per_page" => "10"})
    end
    assert_match(/<input[^>]*type="hidden"[^>]*name="sort"[^>]*value="name"/, output)
    assert_match(/<input[^>]*type="hidden"[^>]*name="direction"[^>]*value="asc"/, output)
    assert_match(/<input[^>]*type="hidden"[^>]*name="per_page"[^>]*value="10"/, output)
  end

  def test_preserved_params_skips_blank_values
    output = phlex do
      RubyUI.DataTableSearch(path: "/x", preserved_params: {"sort" => "", "direction" => nil})
    end
    refute_match(/name="sort"/, output)
    refute_match(/name="direction"/, output)
  end

  def test_preserved_params_skips_the_search_param_itself
    output = phlex do
      RubyUI.DataTableSearch(path: "/x", name: "q", preserved_params: {"q" => "alice", "sort" => "name"})
    end
    refute_match(/<input[^>]*type="hidden"[^>]*name="q"/, output)
    assert_match(/name="sort"/, output)
  end
end
