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

    assert_match(/-mt-4 flex-col/, output)
    assert_match(/pt-4/, output)
    assert_match(/-top-12/, output)
    assert_match(/-bottom-12/, output)
  end

  def test_sets_context_while_rendering
    phlex do
      RubyUI.Carousel(orientation: :test) do
        assert_equal ({orientation: :test}), Thread.current[:ruby_ui__carousel_state]
      end
    end
  end

  def test_clears_context_after_render
    phlex do
      RubyUI.Carousel(orientation: :vertical) do
        RubyUI.CarouselContent do
          RubyUI.CarouselItem { "Item" }
        end
        RubyUI.CarouselPrevious()
        RubyUI.CarouselNext()
      end
    end

    assert_nil Thread.current[:ruby_ui__carousel_state]
  end
end
