# frozen_string_literal: true

require "test_helper"

class RubyUI::CarouselTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::Carousel.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    assert_includes RubyUI::Carousel.new.attrs[:class], "relative"
    assert_includes RubyUI::Carousel.new.attrs[:class], "is-horizontal"
  end

  def test_horizontal_orientation
    comp = RubyUI::Carousel.new(orientation: :horizontal)
    assert_includes comp.attrs[:class], "is-horizontal"
  end

  def test_vertical_orientation
    comp = RubyUI::Carousel.new(orientation: :vertical)
    assert_includes comp.attrs[:class], "is-vertical"
  end

  def test_controller
    comp = RubyUI::Carousel.new
    assert_equal "ruby-ui--carousel", comp.attrs[:data][:controller]
  end

  def test_role
    comp = RubyUI::Carousel.new
    assert_equal "region", comp.attrs[:role]
  end

  def test_extra_attrs_pass_through
    comp = RubyUI::Carousel.new(id: "my-carousel")
    assert_equal "my-carousel", comp.attrs[:id]
  end
end

class RubyUI::CarouselContentTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::CarouselContent.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    assert_includes RubyUI::CarouselContent.new.attrs[:class], "flex"
  end
end

class RubyUI::CarouselItemTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::CarouselItem.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    assert_includes RubyUI::CarouselItem.new.attrs[:class], "min-w-0"
    assert_includes RubyUI::CarouselItem.new.attrs[:class], "basis-full"
  end

  def test_role
    comp = RubyUI::CarouselItem.new
    assert_equal "group", comp.attrs[:role]
  end
end

class RubyUI::CarouselNextTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::CarouselNext.new.is_a?(Phlex::HTML)
  end

  def test_has_button_classes
    comp = RubyUI::CarouselNext.new
    assert_includes comp.attrs[:class], "absolute"
    assert_includes comp.attrs[:class], "rounded-full"
  end

  def test_data_action
    comp = RubyUI::CarouselNext.new
    assert_includes comp.attrs[:data][:action], "click->ruby-ui--carousel#scrollNext"
  end

  def test_data_target
    comp = RubyUI::CarouselNext.new
    assert_equal "nextButton", comp.attrs[:data][:ruby_ui__carousel_target]
  end
end

class RubyUI::CarouselPreviousTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::CarouselPrevious.new.is_a?(Phlex::HTML)
  end

  def test_has_button_classes
    comp = RubyUI::CarouselPrevious.new
    assert_includes comp.attrs[:class], "absolute"
    assert_includes comp.attrs[:class], "rounded-full"
  end

  def test_data_action
    comp = RubyUI::CarouselPrevious.new
    assert_includes comp.attrs[:data][:action], "click->ruby-ui--carousel#scrollPrev"
  end

  def test_data_target
    comp = RubyUI::CarouselPrevious.new
    assert_equal "prevButton", comp.attrs[:data][:ruby_ui__carousel_target]
  end
end
