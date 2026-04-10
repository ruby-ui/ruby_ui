# frozen_string_literal: true

require "test_helper"

class RubyUI::TabsTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::Tabs.new.is_a?(Phlex::HTML)
  end

  def test_controller
    assert_equal "ruby-ui--tabs", RubyUI::Tabs.new.attrs[:data][:controller]
  end

  def test_default_active_value
    t = RubyUI::Tabs.new(default: "account")
    assert_equal "account", t.attrs[:data][:ruby_ui__tabs_active_value]
  end
end

class RubyUI::TabsContentTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::TabsContent.new(value: "tab1").is_a?(Phlex::HTML)
  end

  def test_value_stored
    tc = RubyUI::TabsContent.new(value: "tab1")
    assert_equal "tab1", tc.value
  end

  def test_has_default_class
    assert_includes RubyUI::TabsContent.new(value: "x").attrs[:class], "hidden"
  end
end

class RubyUI::TabsListTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::TabsList.new.is_a?(Phlex::HTML)
  end

  def test_has_default_class
    assert_includes RubyUI::TabsList.new.attrs[:class], "bg-muted"
  end
end

class RubyUI::TabsTriggerTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::TabsTrigger.new(value: "tab1").is_a?(Phlex::HTML)
  end

  def test_value_stored
    tt = RubyUI::TabsTrigger.new(value: "tab1")
    assert_equal "tab1", tt.value
  end

  def test_type
    assert_equal :button, RubyUI::TabsTrigger.new(value: "x").attrs[:type]
  end

  def test_has_default_class
    assert_includes RubyUI::TabsTrigger.new(value: "x").attrs[:class], "rounded-md"
  end
end
