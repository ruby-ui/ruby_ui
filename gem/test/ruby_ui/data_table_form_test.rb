# frozen_string_literal: true

require "test_helper"

class RubyUI::DataTableFormTest < ComponentTest
  def test_renders_form_with_method_post_and_action
    output = erb(%(<%= render RubyUI::DataTableForm.new(action: "/x") %>))
    assert_match(/<form[^>]*action="\/x"[^>]*method="post"|<form[^>]*method="post"[^>]*action="\/x"/, output)
  end

  def test_renders_hidden_authenticity_token
    output = erb(%(<%= render RubyUI::DataTableForm.new %>))
    assert_match(/<input[^>]*type="hidden"[^>]*name="authenticity_token"[^>]*value="[^"]+"/, output)
  end

  def test_yields_children
    output = erb(%(<%= render RubyUI::DataTableForm.new do %>INNER<% end %>))
    assert_match(/INNER/, output)
  end

  def test_renders_form_with_id_attribute_when_given
    output = erb(%(<%= render RubyUI::DataTableForm.new(id: "my_form") %>))
    assert_match(/<form[^>]*id="my_form"/, output)
  end

  def test_renders_form_with_method_get_when_given
    output = erb(%(<%= render RubyUI::DataTableForm.new(method: "get") %>))
    assert_match(/<form[^>]*method="get"/, output)
  end

  def test_renders_form_with_method_delete_when_given
    output = erb(%(<%= render RubyUI::DataTableForm.new(method: "delete") %>))
    assert_match(/<form[^>]*method="delete"/, output)
  end

  # The gem's view context has no controller, so the token is the placeholder
  # the snapshots recorded; a host's view context answers form_authenticity_token.
  def test_uses_the_view_contexts_authenticity_token_when_it_has_one
    view = RubyUI::TestApp.view
    view.define_singleton_method(:form_authenticity_token) { "token-from-the-view" }

    assert_match(/name="authenticity_token"[^>]*value="token-from-the-view"/, view.render(RubyUI::DataTableForm.new))
  end
end
