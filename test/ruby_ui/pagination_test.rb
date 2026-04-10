# frozen_string_literal: true

require "test_helper"

class RubyUI::PaginationTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::Pagination.new.is_a?(Phlex::HTML)
  end

  def test_has_default_class
    assert_includes RubyUI::Pagination.new.attrs[:class], "justify-center"
  end

  def test_aria_label
    assert_equal "pagination", RubyUI::Pagination.new.attrs[:aria][:label]
  end

  def test_role
    assert_equal "navigation", RubyUI::Pagination.new.attrs[:role]
  end
end

class RubyUI::PaginationContentTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::PaginationContent.new.is_a?(Phlex::HTML)
  end

  def test_has_default_class
    assert_includes RubyUI::PaginationContent.new.attrs[:class], "flex-row"
  end
end

class RubyUI::PaginationEllipsisTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::PaginationEllipsis.new.is_a?(Phlex::HTML)
  end

  def test_aria_hidden
    assert_equal true, RubyUI::PaginationEllipsis.new.attrs[:aria][:hidden]
  end

  def test_has_default_class
    assert_includes RubyUI::PaginationEllipsis.new.attrs[:class], "h-9"
  end
end

class RubyUI::PaginationItemTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::PaginationItem.new.is_a?(Phlex::HTML)
  end

  def test_default_href
    assert_equal "#", RubyUI::PaginationItem.new.href
  end

  def test_custom_href
    assert_equal "/page/2", RubyUI::PaginationItem.new(href: "/page/2").href
  end

  def test_active_aria_current
    item = RubyUI::PaginationItem.new(active: true)
    assert_equal "page", item.attrs[:aria][:current]
  end

  def test_inactive_no_aria_current
    item = RubyUI::PaginationItem.new
    assert_nil item.attrs[:aria][:current]
  end

  def test_has_class
    assert RubyUI::PaginationItem.new.attrs[:class]
  end
end
