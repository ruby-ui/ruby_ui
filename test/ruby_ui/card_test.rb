# frozen_string_literal: true

require "test_helper"

class RubyUI::CardTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::Card.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    assert_includes RubyUI::Card.new.attrs[:class], "rounded-xl"
    assert_includes RubyUI::Card.new.attrs[:class], "border"
    assert_includes RubyUI::Card.new.attrs[:class], "bg-background"
  end

  def test_custom_class_merged
    comp = RubyUI::Card.new(class: "w-96")
    assert_includes comp.attrs[:class], "rounded-xl"
    assert_includes comp.attrs[:class], "w-96"
  end

  def test_extra_attrs_pass_through
    comp = RubyUI::Card.new(id: "my-card")
    assert_equal "my-card", comp.attrs[:id]
  end
end

class RubyUI::CardContentTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::CardContent.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    assert_includes RubyUI::CardContent.new.attrs[:class], "p-6"
    assert_includes RubyUI::CardContent.new.attrs[:class], "pt-0"
  end
end

class RubyUI::CardDescriptionTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::CardDescription.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    assert_includes RubyUI::CardDescription.new.attrs[:class], "text-sm"
    assert_includes RubyUI::CardDescription.new.attrs[:class], "text-muted-foreground"
  end
end

class RubyUI::CardFooterTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::CardFooter.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    assert_includes RubyUI::CardFooter.new.attrs[:class], "items-center"
    assert_includes RubyUI::CardFooter.new.attrs[:class], "p-6"
  end
end

class RubyUI::CardHeaderTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::CardHeader.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    assert_includes RubyUI::CardHeader.new.attrs[:class], "flex"
    assert_includes RubyUI::CardHeader.new.attrs[:class], "flex-col"
    assert_includes RubyUI::CardHeader.new.attrs[:class], "p-6"
  end
end

class RubyUI::CardTitleTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::CardTitle.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    assert_includes RubyUI::CardTitle.new.attrs[:class], "font-semibold"
    assert_includes RubyUI::CardTitle.new.attrs[:class], "leading-none"
  end
end
