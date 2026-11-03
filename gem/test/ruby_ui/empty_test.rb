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

  def test_empty_matches_vega_without_visible_border
    output = phlex { RubyUI.Empty { "x" } }

    assert_match(/rounded-lg/, output)
    assert_match(/border-dashed/, output)
    refute_match(/rounded-3xl/, output)
    refute_match(/[" ]border[" ]/, output)
  end

  def test_media_icon_variant_matches_vega
    output = phlex { RubyUI.EmptyMedia(variant: :icon) { "x" } }

    assert_match(/rounded-lg/, output)
    assert_match(/\]:size-6/, output)
    refute_match(/rounded-xl/, output)
    refute_match(/:size-5/, output)
  end

  def test_title_uses_heading_font
    output = phlex { RubyUI.EmptyTitle { "x" } }

    assert_match(/font-heading/, output)
  end
end
