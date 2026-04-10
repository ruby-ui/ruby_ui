# frozen_string_literal: true

require "test_helper"

class RubyUI::TextTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::Text.new.is_a?(Phlex::HTML)
  end

  def test_default_tag_name
    assert_equal "p", RubyUI::Text.new.tag_name
  end

  def test_custom_tag_name
    assert_equal "span", RubyUI::Text.new(as: "span").tag_name
  end

  def test_default_size_class
    t = RubyUI::Text.new
    assert_includes t.attrs[:class], "text-base"
  end

  def test_size_1_xs
    t = RubyUI::Text.new(size: "1")
    assert_includes t.attrs[:class], "text-xs"
  end

  def test_size_2_sm
    t = RubyUI::Text.new(size: "2")
    assert_includes t.attrs[:class], "text-sm"
  end

  def test_size_5_xl
    t = RubyUI::Text.new(size: "5")
    assert_includes t.attrs[:class], "text-xl"
  end

  def test_weight_regular
    t = RubyUI::Text.new(weight: "regular")
    assert_includes t.attrs[:class], "font-normal"
  end

  def test_weight_bold
    t = RubyUI::Text.new(weight: "bold")
    assert_includes t.attrs[:class], "font-bold"
  end

  def test_weight_muted
    t = RubyUI::Text.new(weight: "muted")
    assert_includes t.attrs[:class], "text-muted-foreground"
  end

  def test_user_class_merges
    t = RubyUI::Text.new(class: "extra-class")
    assert_includes t.attrs[:class], "extra-class"
    assert_includes t.attrs[:class], "text-base"
  end

  def test_extra_attrs_pass_through
    t = RubyUI::Text.new(id: "my-text")
    assert_equal "my-text", t.attrs[:id]
  end
end

class RubyUI::HeadingTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::Heading.new.is_a?(Phlex::HTML)
  end

  def test_default_tag_name
    assert_equal "h1", RubyUI::Heading.new.tag_name
  end

  def test_level_1_tag
    assert_equal "h1", RubyUI::Heading.new(level: "1").tag_name
  end

  def test_level_2_tag
    assert_equal "h2", RubyUI::Heading.new(level: "2").tag_name
  end

  def test_as_overrides_level
    assert_equal "h3", RubyUI::Heading.new(level: "1", as: "h3").tag_name
  end

  def test_default_class_includes_font_bold
    h = RubyUI::Heading.new
    assert_includes h.attrs[:class], "font-bold"
    assert_includes h.attrs[:class], "scroll-m-20"
  end

  def test_level_1_gets_large_size
    h = RubyUI::Heading.new(level: "1")
    assert_includes h.attrs[:class], "text-3xl"
  end

  def test_level_2_gets_2xl
    h = RubyUI::Heading.new(level: "2")
    assert_includes h.attrs[:class], "text-2xl"
  end

  def test_custom_size_7
    h = RubyUI::Heading.new(size: "7")
    assert_includes h.attrs[:class], "text-3xl"
  end
end

class RubyUI::TypographyBlockquoteTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::TypographyBlockquote.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    bq = RubyUI::TypographyBlockquote.new
    assert_includes bq.attrs[:class], "border-l-2"
    assert_includes bq.attrs[:class], "italic"
  end
end
