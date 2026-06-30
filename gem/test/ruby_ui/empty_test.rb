# frozen_string_literal: true

require "test_helper"

class RubyUI::EmptyTest < ComponentTest
  def test_renders_full_structure
    output = phlex do
      RubyUI.Empty do
        RubyUI.EmptyHeader do
          RubyUI.EmptyMedia(variant: :icon) { "icon" }
          RubyUI.EmptyTitle { "Nothing here" }
          RubyUI.EmptyDescription { "No content yet." }
        end
        RubyUI.EmptyContent { "action" }
      end
    end

    assert_match(/data-slot="empty"/, output)
    assert_match(/data-slot="empty-header"/, output)
    assert_match(/data-slot="empty-icon"/, output)
    assert_match(/data-slot="empty-title"/, output)
    assert_match(/data-slot="empty-description"/, output)
    assert_match(/data-slot="empty-content"/, output)
    assert_match(/Nothing here/, output)
  end

  def test_media_default_variant
    output = phlex { RubyUI.EmptyMedia { "x" } }

    assert_match(/data-variant="default"/, output)
  end

  def test_media_icon_variant
    output = phlex { RubyUI.EmptyMedia(variant: :icon) { "x" } }

    assert_match(/data-variant="icon"/, output)
    assert_match(/bg-muted/, output)
  end
end
