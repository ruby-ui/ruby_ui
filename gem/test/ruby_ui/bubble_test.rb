# frozen_string_literal: true

require "test_helper"

class RubyUI::BubbleTest < ComponentTest
  def test_renders_content
    output = phlex do
      RubyUI.Bubble do
        RubyUI.BubbleContent { "Hello" }
      end
    end

    assert_match(/Hello/, output)
    assert_match(/data-slot="bubble"/, output)
    assert_match(/data-slot="bubble-content"/, output)
  end

  def test_default_variant_and_align
    output = phlex { RubyUI.Bubble { RubyUI.BubbleContent { "Hi" } } }

    assert_match(/data-variant="default"/, output)
    assert_match(/data-align="start"/, output)
  end

  def test_variant_and_align_attributes
    output = phlex do
      RubyUI.Bubble(variant: :muted, align: :end) { RubyUI.BubbleContent { "Hi" } }
    end

    assert_match(/data-variant="muted"/, output)
    assert_match(/data-align="end"/, output)
  end

  def test_reactions_defaults_to_bottom_end
    output = phlex do
      RubyUI.Bubble do
        RubyUI.BubbleContent { "Hi" }
        RubyUI.BubbleReactions { "👍" }
      end
    end

    assert_match(/data-slot="bubble-reactions"/, output)
    assert_match(/data-side="bottom"/, output)
    assert_match(/data-align="end"/, output)
  end

  def test_reactions_side_and_align
    output = phlex do
      RubyUI.BubbleReactions(side: :top, align: :start) { "🔥" }
    end

    assert_match(/data-side="top"/, output)
    assert_match(/data-align="start"/, output)
  end

  def test_content_renders_as_anchor
    output = phlex do
      RubyUI.Bubble { RubyUI.BubbleContent(as: :a, href: "#") { "Open" } }
    end

    assert_match(/<a[^>]*data-slot="bubble-content"[^>]*href="#"/, output)
    assert_match(/Open/, output)
  end

  def test_content_renders_as_button
    output = phlex do
      RubyUI.Bubble { RubyUI.BubbleContent(as: :button, type: "button") { "Retry" } }
    end

    assert_match(/<button[^>]*data-slot="bubble-content"/, output)
  end

  def test_group_wraps_bubbles
    output = phlex do
      RubyUI.BubbleGroup do
        RubyUI.Bubble { RubyUI.BubbleContent { "a" } }
        RubyUI.Bubble { RubyUI.BubbleContent { "b" } }
      end
    end

    assert_match(/data-slot="bubble-group"/, output)
  end
end
