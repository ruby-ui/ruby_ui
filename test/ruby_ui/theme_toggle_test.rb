# frozen_string_literal: true

require "test_helper"

class RubyUI::ThemeToggleTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::ThemeToggle.new.is_a?(Phlex::HTML)
  end

  def test_empty_attrs
    assert_equal({}, RubyUI::ThemeToggle.new.attrs)
  end
end

class RubyUI::SetDarkModeTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::SetDarkMode.new.is_a?(Phlex::HTML)
  end

  def test_has_default_class
    assert_includes RubyUI::SetDarkMode.new.attrs[:class], "dark:inline-block"
  end

  def test_controller
    assert_equal "ruby-ui--theme-toggle", RubyUI::SetDarkMode.new.attrs[:data][:controller]
  end
end

class RubyUI::SetLightModeTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::SetLightMode.new.is_a?(Phlex::HTML)
  end

  def test_has_default_class
    assert_includes RubyUI::SetLightMode.new.attrs[:class], "dark:hidden"
  end

  def test_controller
    assert_equal "ruby-ui--theme-toggle", RubyUI::SetLightMode.new.attrs[:data][:controller]
  end
end
