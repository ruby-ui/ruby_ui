# frozen_string_literal: true

require "test_helper"

class RubyUI::AttachmentTest < ComponentTest
  def test_render_with_all_parts
    output = phlex do
      RubyUI.AttachmentGroup do
        RubyUI.Attachment do
          RubyUI.AttachmentMedia { "icon" }
          RubyUI.AttachmentContent do
            RubyUI.AttachmentTitle { "report.pdf" }
            RubyUI.AttachmentDescription { "PDF · 2.4 MB" }
          end
          RubyUI.AttachmentActions do
            RubyUI.AttachmentAction(aria_label: "Remove report.pdf") { "x" }
          end
          RubyUI.AttachmentTrigger(aria_label: "Open report.pdf")
        end
      end
    end

    %w[attachment-group attachment attachment-media attachment-content attachment-title
      attachment-description attachment-actions attachment-action attachment-trigger].each do |slot|
      assert_match(/data-slot="#{slot}"/, output)
    end
    assert_match(/report\.pdf/, output)
    assert_match(/PDF · 2\.4 MB/, output)
  end

  def test_attachment_defaults
    output = phlex { RubyUI.Attachment { "a" } }

    assert_match(/data-state="done"/, output)
    assert_match(/data-size="default"/, output)
    assert_match(/data-orientation="horizontal"/, output)
    assert_match(/group\/attachment/, output)
    assert_match(/min-w-40/, output)
    assert_match(/has-data-\[slot=attachment-content\]:px-2\.5/, output)
  end

  def test_attachment_size_orientation_and_state
    output = phlex { RubyUI.Attachment(state: :error, size: :xs, orientation: :vertical) { "a" } }

    assert_match(/data-state="error"/, output)
    assert_match(/data-size="xs"/, output)
    assert_match(/data-orientation="vertical"/, output)
    assert_match(/rounded-lg/, output)
    refute_match(/rounded-xl/, output)
    assert_match(/\bw-24\b/, output)
    refute_match(/\bw-fit\b/, output)
    refute_match(/min-w-40/, output)
  end

  def test_attachment_falls_back_on_unknown_values
    output = phlex { RubyUI.Attachment(state: :bogus, size: :huge, orientation: :diagonal) { "a" } }

    assert_match(/data-state="done"/, output)
    assert_match(/data-size="default"/, output)
    assert_match(/data-orientation="horizontal"/, output)
  end

  def test_media_variants
    icon = phlex { RubyUI.AttachmentMedia { "i" } }
    image = phlex { RubyUI.AttachmentMedia(variant: :image) { "i" } }

    assert_match(/data-variant="icon"/, icon)
    refute_match(/opacity-60/, icon)
    assert_match(/data-variant="image"/, image)
    assert_match(/opacity-60/, image)
    assert_match(/\*:\[img\]:object-cover/, image)
  end

  def test_title_shimmers_while_loading
    output = phlex { RubyUI.AttachmentTitle { "a.pdf" } }

    assert_match(/group-data-\[state=uploading\]\/attachment:shimmer/, output)
    assert_match(/group-data-\[state=processing\]\/attachment:shimmer/, output)
    assert_match(/<span/, output)
  end

  def test_action_is_a_ghost_icon_xs_button
    output = phlex { RubyUI.AttachmentAction(aria_label: "Remove") { "x" } }

    assert_match(/<button/, output)
    assert_match(/type="button"/, output)
    assert_match(/data-slot="attachment-action"/, output)
    refute_match(/data-slot="button"/, output)
    assert_match(/aria-label="Remove"/, output)
    assert_match(/\bh-6 w-6\b/, output)
    assert_match(/hover:bg-muted/, output)
    refute_match(/bg-primary/, output)
  end

  def test_action_takes_button_options
    output = phlex { RubyUI.AttachmentAction(variant: :destructive, href: "/files/1", aria_label: "Download") { "d" } }

    assert_match(/<a /, output)
    assert_match(/href="\/files\/1"/, output)
    assert_match(/text-destructive/, output)
  end

  def test_trigger_renders_button_or_link
    button = phlex { RubyUI.AttachmentTrigger(aria_label: "Open") }
    link = phlex { RubyUI.AttachmentTrigger(as: :a, href: "/files/1", aria_label: "Open") }

    assert_match(/<button[^>]*type="button"/, button)
    assert_match(/absolute inset-0 z-10 outline-none/, button)
    assert_match(/<a /, link)
    refute_match(/type=/, link)
    assert_match(/href="\/files\/1"/, link)
  end

  def test_group_scrolls_and_snaps
    output = phlex { RubyUI.AttachmentGroup { "g" } }

    assert_match(/overflow-x-auto/, output)
    assert_match(/snap-mandatory/, output)
    assert_match(/scroll-fade-x/, output)
    assert_match(/scrollbar-none/, output)
    assert_match(/\*:data-\[slot=attachment\]:snap-start/, output)
  end
end
