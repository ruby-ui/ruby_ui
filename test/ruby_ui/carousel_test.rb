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
end
