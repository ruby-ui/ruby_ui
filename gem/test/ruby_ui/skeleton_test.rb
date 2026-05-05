# frozen_string_literal: true

require "test_helper"

class RubyUI::SkeletonTest < ComponentTest
  def test_render
    output = phlex do
      RubyUI::Skeleton(class: "w-14 h-14")
    end

    assert_match(/div/, output)
    assert_match(/w-14/, output)
    assert_match(/h-14/, output)
  end
end
