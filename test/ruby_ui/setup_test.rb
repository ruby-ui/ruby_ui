# frozen_string_literal: true

require "test_helper"

class RubyUI::SetupTest < Minitest::Test
  def setup
    @original_namespace = RubyUI.namespace
  end

  def teardown
    RubyUI.namespace = @original_namespace
    Object.send(:remove_const, :UI) if Object.const_defined?(:UI)
  end

  def test_default_namespace
    RubyUI.setup {}

    assert_nil RubyUI.namespace
    assert_kind_of RubyUI::Base, RubyUI::Button.new
  end

  def test_custom_namespace
    RubyUI.setup do |config|
      config.namespace = "UI"
    end

    assert_equal "UI", RubyUI.namespace
    assert_equal RubyUI::Base, UI::Base
    assert_kind_of RubyUI::Base, UI::Button.new
  end
end
