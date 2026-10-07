# frozen_string_literal: true

require "test_helper"

class RubyUI::ThemeToggleTest < ComponentTest
  def test_renders_as_toggle_button
    output = erb(%(<%= render RubyUI::ThemeToggle.new do %>icon<% end %>))
    assert_match(/<button[^>]*type="button"/, output)
    assert_match(/aria-pressed=/, output)
  end

  def test_wires_theme_toggle_controller
    output = erb(%(<%= render RubyUI::ThemeToggle.new do %>icon<% end %>))
    assert_match(/data-controller="[^"]*ruby-ui--theme-toggle/, output)
    assert_match(/data-controller="[^"]*ruby-ui--toggle/, output)
    assert_match(/#{descriptor("ruby-ui--toggle:change->ruby-ui--theme-toggle#apply")}/, output)
  end

  def test_block_content_rendered
    output = erb(%(<%= render RubyUI::ThemeToggle.new do %>SUN_AND_MOON<% end %>))
    assert_match(/SUN_AND_MOON/, output)
  end
end
