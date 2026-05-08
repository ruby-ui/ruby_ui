# frozen_string_literal: true

require "test_helper"

class RubyUI::TooltipTest < ComponentTest
  def test_render_with_all_items
    output = phlex do
      RubyUI.Tooltip do
        RubyUI.TooltipTrigger do
          RubyUI.Button(variant: :outline, icon: true) { "?" }
        end
        RubyUI.TooltipContent do
          RubyUI::Text(as: "p") { "Add to library" }
        end
      end
    end

    assert_match(/Add to library/, output)
  end

  def test_tooltip_content_wraps_long_text_within_viewport
    output = phlex do
      RubyUI.TooltipContent { "Long tooltip content" }
    end

    assert_match(/w-fit/, output)
    assert_match(/max-w-\[calc\(100vw-2rem\)\]/, output)
    assert_match(/break-words/, output)
  end
end
