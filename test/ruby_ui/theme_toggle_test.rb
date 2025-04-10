# frozen_string_literal: true

require "test_helper"

class RubyUI::ThemeToggleTest < ComponentTest
  def test_render_with_all_items
    output = phlex do
      RubyUI.ThemeToggle do |toggle|
        RubyUI.SetLightMode do
          RubyUI.Button(variant: :primary) { "Light" }
        end

        RubyUI.SetDarkMode do
          RubyUI.Button(variant: :primary) { "Dark" }
        end
      end
    end

    assert_match(/Dark/, output)
  end
end
