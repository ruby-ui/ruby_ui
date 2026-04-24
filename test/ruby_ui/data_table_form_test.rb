# frozen_string_literal: true

require "test_helper"

class RubyUI::DataTableFormTest < ComponentTest
  def test_renders_form_with_method_post_and_action
    output = phlex { RubyUI.DataTableForm(action: "/x") }
    assert_match(/<form[^>]*action="\/x"[^>]*method="post"|<form[^>]*method="post"[^>]*action="\/x"/, output)
  end

  def test_renders_hidden_authenticity_token
    output = phlex { RubyUI.DataTableForm() }
    assert_match(/<input[^>]*type="hidden"[^>]*name="authenticity_token"[^>]*value="[^"]+"/, output)
  end

  def test_yields_children
    output = phlex { RubyUI.DataTableForm() { "INNER" } }
    assert_match(/INNER/, output)
  end

  def test_renders_form_with_id_attribute_when_given
    output = phlex { RubyUI.DataTableForm(id: "my_form") }
    assert_match(/<form[^>]*id="my_form"/, output)
  end

  def test_renders_form_with_method_get_when_given
    output = phlex { RubyUI.DataTableForm(method: "get") }
    assert_match(/<form[^>]*method="get"/, output)
  end

  def test_renders_form_with_method_delete_when_given
    output = phlex { RubyUI.DataTableForm(method: "delete") }
    assert_match(/<form[^>]*method="delete"/, output)
  end
end
