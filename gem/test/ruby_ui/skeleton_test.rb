# frozen_string_literal: true

require "test_helper"

class RubyUI::SkeletonTest < ComponentTest
  def test_render
    output = phlex do
      RubyUI.Skeleton(class: "w-14 h-14")
    end

    assert_match(/<div/, output)
    assert_match(/data-slot="skeleton"/, output)
    assert_match(/animate-pulse rounded-md bg-muted/, output)
    assert_match(/w-14/, output)
    assert_match(/h-14/, output)
    refute_match(/bg-primary/, output)
  end

  def test_class_overrides_radius
    output = phlex do
      RubyUI.Skeleton(class: "rounded-full")
    end

    assert_match(/rounded-full/, output)
    refute_match(/rounded-md/, output)
  end

  def test_merges_data_attributes
    output = phlex do
      RubyUI.Skeleton(data: {testid: "loading"})
    end

    assert_match(/data-slot="skeleton"/, output)
    assert_match(/data-testid="loading"/, output)
  end
end
