# frozen_string_literal: true

require "test_helper"

class RubyUI::ToggleTest < ComponentTest
  def test_render_with_default_variant_and_size
    output = phlex do
      RubyUI.Toggle { "Default Toggle" }
    end

    assert_match(/Default Toggle/, output)
    assert_match(/data-state="off"/, output)
    assert_match(/data-controller="ruby-ui--toggle"/, output)
    assert_match(/h-10 px-3 min-w-10/, output)
    assert_match(/bg-transparent/, output)
  end

  def test_render_with_custom_variant_and_size
    output = phlex do
      RubyUI.Toggle(variant: :outline, size: :lg) { "Custom Toggle" }
    end

    assert_match(/Custom Toggle/, output)
    assert_match(/data-state="off"/, output)
    assert_match(/h-11 px-5 min-w-11/, output)
    assert_match(/border border-input bg-transparent hover:bg-accent hover:text-accent-foreground/, output)
  end
end
