# frozen_string_literal: true

require "test_helper"

class RubyUI::CarouselTest < ComponentTest
  def test_render_with_all_items
    output = phlex do
      RubyUI.Carousel do
        RubyUI.CarouselContent do
          RubyUI.CarouselItem { "Item" }
        end
        RubyUI.CarouselPrevious()
        RubyUI.CarouselNext()
      end
    end

    assert_match(/Item/, output)
    assert_match(/button/, output)
    assert_match(/ is-horizontal/, output)
  end

  def test_render_with_horizontal_orientation
    output = phlex do
      RubyUI.Carousel(orientation: :horizontal) do
        RubyUI.CarouselContent() do
          RubyUI.CarouselItem() { "Item" }
        end
        RubyUI.CarouselPrevious()
        RubyUI.CarouselNext()
      end
    end

    assert_match(/ is-horizontal/, output)
  end

  def test_render_with_vertical_orientation
    output = phlex do
      RubyUI.Carousel(orientation: :vertical) do
        RubyUI.CarouselContent() do
          RubyUI.CarouselItem() { "Item" }
        end
        RubyUI.CarouselPrevious()
        RubyUI.CarouselNext()
      end
    end

    assert_match(/ is-vertical/, output)
  end

  def test_data_slot_on_every_part
    output = render_carousel

    {
      "carousel" => "div", "carousel-content" => "div", "carousel-item" => "div",
      "carousel-previous" => "button", "carousel-next" => "button"
    }.each do |slot, tag|
      assert opening_tag(output, slot).start_with?("<#{tag} "), "#{slot} should be a <#{tag}>"
    end
  end

  # Button sets data-slot="button"; Previous/Next replace it rather than
  # appending to it.
  def test_buttons_replace_the_button_slot
    output = render_carousel

    refute_match(/data-slot="button/, output)
    refute_match(/data-slot="[^"]* carousel-/, output)
  end

  def test_content_slot_is_the_viewport
    tag = opening_tag(render_carousel, "carousel-content")

    assert_includes tag, 'data-ruby-ui--carousel-target="viewport"'
    assert_includes tag, 'class="overflow-hidden"'
  end

  def test_buttons_are_named_after_their_action
    output = render_carousel

    assert_match(%r{data-slot="carousel-previous".*?<span class="sr-only">Previous slide</span>}m, output)
    assert_match(%r{data-slot="carousel-next".*?<span class="sr-only">Next slide</span>}m, output)
  end

  def test_buttons_use_chevrons_mirrored_in_rtl
    previous = phlex { RubyUI.CarouselPrevious() }
    next_button = phlex { RubyUI.CarouselNext() }

    assert_includes previous, 'd="m15 18-6-6 6-6"'
    assert_includes next_button, 'd="m9 18 6-6-6-6"'
    [previous, next_button].each do |output|
      assert_match(/<svg[^>]*class="rtl:rotate-180"/, output)
      assert_match(/<svg[^>]*aria-hidden="true"/, output)
    end
  end

  def test_buttons_use_touch_manipulation
    output = render_carousel

    assert_includes opening_tag(output, "carousel-previous"), "touch-manipulation"
    assert_includes opening_tag(output, "carousel-next"), "touch-manipulation"
  end

  # No loop unless asked for, as in shadcn (Embla's default).
  def test_options_have_no_loop_by_default
    tag = opening_tag(render_carousel, "carousel")

    assert_includes tag, %(data-ruby-ui--carousel-options-value="{&quot;axis&quot;:&quot;x&quot;}")
  end

  def test_loop_can_be_turned_on
    tag = opening_tag(phlex { RubyUI.Carousel(options: {loop: true}) }, "carousel")

    assert_includes tag, "&quot;loop&quot;:true"
  end

  # Orientation classes are plain utilities (via the render context), so a
  # caller's class replaces them, as shadcn's cn does.
  def test_caller_spacing_overrides_the_default
    output = phlex do
      RubyUI.Carousel do
        RubyUI.CarouselContent(class: "-ml-1") { RubyUI.CarouselItem(class: "pl-1") { "Item" } }
      end
    end

    item = opening_tag(output, "carousel-item")
    assert_equal %w[-ml-1 flex], track_classes(output)
    refute_includes output, "-ml-4"
    assert_includes item, "pl-1"
    refute_includes item, "pl-4"
  end

  def test_horizontal_classes
    output = render_carousel

    assert_equal %w[-ml-4 flex], track_classes(output)
    assert_includes opening_tag(output, "carousel-item"), "pl-4"
    assert_includes opening_tag(output, "carousel-previous"), "-left-12 top-1/2 -translate-y-1/2"
    assert_includes opening_tag(output, "carousel-next"), "-right-12 top-1/2 -translate-y-1/2"
  end

  def test_vertical_classes
    output = phlex do
      RubyUI.Carousel(orientation: :vertical) do
        RubyUI.CarouselContent { RubyUI.CarouselItem { "Item" } }
        RubyUI.CarouselPrevious()
        RubyUI.CarouselNext()
      end
    end

    item = opening_tag(output, "carousel-item")
    assert_equal %w[-mt-4 flex flex-col], track_classes(output)
    assert_includes item, "pt-4"
    refute_includes item, "pl-4"
    assert_includes opening_tag(output, "carousel-previous"), "-top-12 left-1/2 -translate-x-1/2 rotate-90"
    assert_includes opening_tag(output, "carousel-next"), "-bottom-12 left-1/2 -translate-x-1/2 rotate-90"
    assert_includes opening_tag(output, "carousel"), "&quot;axis&quot;:&quot;y&quot;"
  end

  # Outside a Carousel (or after one closes) the parts fall back to horizontal.
  def test_orientation_does_not_leak_past_the_carousel
    output = phlex do
      RubyUI.Carousel(orientation: :vertical) { RubyUI.CarouselContent { "A" } }
      RubyUI.CarouselItem { "B" }
    end

    assert_includes opening_tag(output, "carousel-item"), "pl-4"
  end

  private

  def render_carousel
    phlex do
      RubyUI.Carousel do
        RubyUI.CarouselContent do
          RubyUI.CarouselItem { "Item" }
        end
        RubyUI.CarouselPrevious()
        RubyUI.CarouselNext()
      end
    end
  end

  # Classes of the flex track inside CarouselContent, sorted.
  def track_classes(output)
    output[/data-slot="carousel-content"[^>]*><div class="([^"]*)"/, 1].split.sort
  end

  def opening_tag(output, slot)
    output[/<[a-z]+\b(?:[^>"]|"[^"]*")*data-slot="#{slot}"(?:[^>"]|"[^"]*")*>/] || flunk("no #{slot} in #{output}")
  end
end
