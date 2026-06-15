# frozen_string_literal: true

require "test_helper"

class RubyUI::TabsTriggerTest < ComponentTest
  def test_renders_as_button_by_default
    output = phlex { RubyUI.TabsTrigger(value: "account") { "Account" } }

    assert_match(/\A<button/, output)
    assert_match(/type="button"/, output)
    assert_match(/Account/, output)
    refute_match(/<a[\s>]/, output)
  end

  def test_renders_as_anchor_with_href_when_as_a
    output = phlex { RubyUI.TabsTrigger(value: "account", as: :a, href: "/account") { "Account" } }

    assert_match(/\A<a/, output)
    assert_match(/href="\/account"/, output)
    assert_match(/Account/, output)
    refute_match(/<button/, output)
    refute_match(/type="button"/, output)
  end

  def test_unexpected_as_value_still_renders_a_typed_button
    output = phlex { RubyUI.TabsTrigger(value: "account", as: :buton) { "Account" } }

    assert_match(/\A<button/, output)
    assert_match(/type="button"/, output)
  end

  def test_keeps_trigger_data_attributes_when_rendered_as_anchor
    output = phlex { RubyUI.TabsTrigger(value: "account", as: :a, href: "/account") { "Account" } }

    assert_match(/data-ruby-ui--tabs-target="trigger"/, output)
    assert_match(/data-value="account"/, output)
  end
end
