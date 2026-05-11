# frozen_string_literal: true

require "test_helper"

class RubyUI::ThemeToggleTest < ComponentTest
  def test_renders_as_toggle_button
    output = phlex { RubyUI.ThemeToggle { "icon" } }
    assert_match(/<button[^>]*type="button"/, output)
    assert_match(/aria-pressed=/, output)
  end

  def test_wires_theme_toggle_controller
    output = phlex { RubyUI.ThemeToggle { "icon" } }
    assert_match(/data-controller="[^"]*ruby-ui--theme-toggle/, output)
    assert_match(/data-controller="[^"]*ruby-ui--toggle/, output)
    assert_match(/ruby-ui:toggle:change->ruby-ui--theme-toggle#apply/, output)
  end

  def test_block_content_rendered
    output = phlex { RubyUI.ThemeToggle { "SUN_AND_MOON" } }
    assert_match(/SUN_AND_MOON/, output)
  end
end
