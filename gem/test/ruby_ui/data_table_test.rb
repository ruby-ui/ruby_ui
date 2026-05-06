# frozen_string_literal: true

require "test_helper"

class RubyUI::DataTableTest < ComponentTest
  def test_renders_turbo_frame_with_given_id
    output = phlex { RubyUI.DataTable(id: "employees") }
    assert_match %r{<turbo-frame[^>]*id="employees"[^>]*target="_top"}, output
  end

  def test_sets_data_controller_on_inner_div
    output = phlex { RubyUI.DataTable(id: "x") }
    assert_match(/data-controller="ruby-ui--data-table"/, output)
  end

  def test_does_not_render_a_form_wrapper
    output = phlex { RubyUI.DataTable(id: "x") }
    refute_match(/<form/, output)
  end

  def test_renders_children_inside_the_div
    output = phlex { RubyUI.DataTable(id: "x") { "INNER" } }
    assert_match(/INNER/, output)
  end
end
