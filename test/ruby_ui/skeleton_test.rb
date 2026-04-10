# frozen_string_literal: true

require "test_helper"

class RubyUI::SkeletonTest < Minitest::Test
  def test_not_phlex
    refute RubyUI::Skeleton.new.is_a?(Phlex::HTML)
  end

  def test_has_default_class
    assert_includes RubyUI::Skeleton.new.attrs[:class], "animate-pulse"
  end

  def test_user_class_merged
    s = RubyUI::Skeleton.new(class: "w-14 h-14")
    assert_includes s.attrs[:class], "w-14"
    assert_includes s.attrs[:class], "h-14"
    assert_includes s.attrs[:class], "animate-pulse"
  end
end
