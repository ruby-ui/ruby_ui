# frozen_string_literal: true

require "test_helper"

class RubyUI::AvatarTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::Avatar.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    assert_includes RubyUI::Avatar.new.attrs[:class], "rounded-full"
    assert_includes RubyUI::Avatar.new.attrs[:class], "h-10"
    assert_includes RubyUI::Avatar.new.attrs[:class], "w-10"
  end

  def test_size_sm
    comp = RubyUI::Avatar.new(size: :sm)
    assert_includes comp.attrs[:class], "h-6"
    assert_includes comp.attrs[:class], "w-6"
  end

  def test_size_lg
    comp = RubyUI::Avatar.new(size: :lg)
    assert_includes comp.attrs[:class], "h-14"
    assert_includes comp.attrs[:class], "w-14"
  end

  def test_custom_class_merged
    comp = RubyUI::Avatar.new(class: "custom")
    assert_includes comp.attrs[:class], "rounded-full"
    assert_includes comp.attrs[:class], "custom"
  end

  def test_extra_attrs_pass_through
    comp = RubyUI::Avatar.new(id: "my-avatar")
    assert_equal "my-avatar", comp.attrs[:id]
  end
end

class RubyUI::AvatarFallbackTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::AvatarFallback.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    assert_includes RubyUI::AvatarFallback.new.attrs[:class], "rounded-full"
    assert_includes RubyUI::AvatarFallback.new.attrs[:class], "bg-muted"
  end
end

class RubyUI::AvatarImageTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::AvatarImage.new(src: "/img.png").is_a?(Phlex::HTML)
  end

  def test_src_attr
    comp = RubyUI::AvatarImage.new(src: "/img.png")
    assert_equal "/img.png", comp.attrs[:src]
  end

  def test_alt_default
    comp = RubyUI::AvatarImage.new(src: "/img.png")
    assert_equal "", comp.attrs[:alt]
  end

  def test_alt_custom
    comp = RubyUI::AvatarImage.new(src: "/img.png", alt: "User")
    assert_equal "User", comp.attrs[:alt]
  end

  def test_default_class
    comp = RubyUI::AvatarImage.new(src: "/img.png")
    assert_includes comp.attrs[:class], "aspect-square"
    assert_includes comp.attrs[:class], "h-full"
  end
end
