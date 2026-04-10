# frozen_string_literal: true

require "test_helper"

class RubyUI::BreadcrumbTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::Breadcrumb.new.is_a?(Phlex::HTML)
  end

  def test_aria_label
    comp = RubyUI::Breadcrumb.new
    assert_equal "breadcrumb", comp.attrs[:aria][:label]
  end

  def test_extra_attrs_pass_through
    comp = RubyUI::Breadcrumb.new(id: "nav")
    assert_equal "nav", comp.attrs[:id]
  end
end

class RubyUI::BreadcrumbEllipsisTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::BreadcrumbEllipsis.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    assert_includes RubyUI::BreadcrumbEllipsis.new.attrs[:class], "flex"
    assert_includes RubyUI::BreadcrumbEllipsis.new.attrs[:class], "h-9"
  end

  def test_aria_hidden
    comp = RubyUI::BreadcrumbEllipsis.new
    assert_equal true, comp.attrs[:aria][:hidden]
  end

  def test_role
    comp = RubyUI::BreadcrumbEllipsis.new
    assert_equal "presentation", comp.attrs[:role]
  end
end

class RubyUI::BreadcrumbItemTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::BreadcrumbItem.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    assert_includes RubyUI::BreadcrumbItem.new.attrs[:class], "inline-flex"
    assert_includes RubyUI::BreadcrumbItem.new.attrs[:class], "items-center"
  end
end

class RubyUI::BreadcrumbLinkTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::BreadcrumbLink.new.is_a?(Phlex::HTML)
  end

  def test_default_href
    comp = RubyUI::BreadcrumbLink.new
    assert_equal "#", comp.attrs[:href]
  end

  def test_custom_href
    comp = RubyUI::BreadcrumbLink.new(href: "/home")
    assert_equal "/home", comp.attrs[:href]
  end

  def test_default_class
    assert_includes RubyUI::BreadcrumbLink.new.attrs[:class], "hover:text-foreground"
  end
end

class RubyUI::BreadcrumbListTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::BreadcrumbList.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    assert_includes RubyUI::BreadcrumbList.new.attrs[:class], "flex"
    assert_includes RubyUI::BreadcrumbList.new.attrs[:class], "flex-wrap"
    assert_includes RubyUI::BreadcrumbList.new.attrs[:class], "text-sm"
  end
end

class RubyUI::BreadcrumbPageTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::BreadcrumbPage.new.is_a?(Phlex::HTML)
  end

  def test_default_class
    assert_includes RubyUI::BreadcrumbPage.new.attrs[:class], "text-foreground"
  end

  def test_aria_current
    comp = RubyUI::BreadcrumbPage.new
    assert_equal "page", comp.attrs[:aria][:current]
  end

  def test_role
    comp = RubyUI::BreadcrumbPage.new
    assert_equal "link", comp.attrs[:role]
  end
end

class RubyUI::BreadcrumbSeparatorTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::BreadcrumbSeparator.new.is_a?(Phlex::HTML)
  end

  def test_aria_hidden
    comp = RubyUI::BreadcrumbSeparator.new
    assert_equal true, comp.attrs[:aria][:hidden]
  end

  def test_role
    comp = RubyUI::BreadcrumbSeparator.new
    assert_equal "presentation", comp.attrs[:role]
  end
end
