# frozen_string_literal: true

require "test_helper"

class RubyUI::SheetTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::Sheet.new.is_a?(Phlex::HTML)
  end

  def test_controller
    assert_equal "ruby-ui--sheet", RubyUI::Sheet.new.attrs[:data][:controller]
  end
end

class RubyUI::SheetContentTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::SheetContent.new.is_a?(Phlex::HTML)
  end

  def test_default_side
    assert_equal :right, RubyUI::SheetContent.new.side
  end

  def test_side_classes_right
    sc = RubyUI::SheetContent.new(side: :right)
    assert_includes sc.attrs[:class], "inset-y-0"
  end

  def test_side_classes_left
    sc = RubyUI::SheetContent.new(side: :left)
    assert_includes sc.attrs[:class], "inset-y-0"
    assert_includes sc.attrs[:class], "left-0"
  end

  def test_backdrop_attrs
    sc = RubyUI::SheetContent.new
    assert sc.backdrop_attrs[:class]
    assert_includes sc.backdrop_attrs[:class], "backdrop-blur-sm"
  end

  def test_has_default_class
    assert_includes RubyUI::SheetContent.new.attrs[:class], "bg-background"
  end
end

class RubyUI::SheetDescriptionTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::SheetDescription.new.is_a?(Phlex::HTML)
  end

  def test_has_default_class
    assert_includes RubyUI::SheetDescription.new.attrs[:class], "muted-foreground"
  end
end

class RubyUI::SheetFooterTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::SheetFooter.new.is_a?(Phlex::HTML)
  end

  def test_has_default_class
    assert_includes RubyUI::SheetFooter.new.attrs[:class], "flex-col-reverse"
  end
end

class RubyUI::SheetHeaderTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::SheetHeader.new.is_a?(Phlex::HTML)
  end

  def test_has_default_class
    assert_includes RubyUI::SheetHeader.new.attrs[:class], "space-y-1.5"
  end
end

class RubyUI::SheetMiddleTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::SheetMiddle.new.is_a?(Phlex::HTML)
  end

  def test_has_default_class
    assert_includes RubyUI::SheetMiddle.new.attrs[:class], "py-4"
  end
end

class RubyUI::SheetTitleTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::SheetTitle.new.is_a?(Phlex::HTML)
  end

  def test_has_default_class
    assert_includes RubyUI::SheetTitle.new.attrs[:class], "font-semibold"
  end
end

class RubyUI::SheetTriggerTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::SheetTrigger.new.is_a?(Phlex::HTML)
  end

  def test_data_action
    assert_equal "click->ruby-ui--sheet#open", RubyUI::SheetTrigger.new.attrs[:data][:action]
  end
end
