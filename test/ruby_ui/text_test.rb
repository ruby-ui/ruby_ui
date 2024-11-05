# frozen_string_literal: true

require "test_helper"

class RubyUI::TypographyTest < Minitest::Test
  include Phlex::Testing::ViewHelper

  def test_heading_with_levels
    (1..4).each do |level|
      output = phlex_context do
        RubyUI::Heading(level: level.to_s) { "This is an H#{level} title" }
      end

      assert_match("This is an H#{level} title", output)
      assert_match(/<h#{level}/, output)
    end
  end

  def test_heading_with_custom_size
    output = phlex_context do
      RubyUI::Heading(as: "h2", size: "7") { "Custom Heading" }
    end

    assert_match("Custom Heading", output)
    assert_match(/<h2/, output)
    assert_match(/text-3xl/, output)
  end

  def test_text_with_sizes
    (1..9).each do |size|
      output = phlex_context do
        RubyUI::Text(size: size.to_s) { "Size #{size} text" }
      end

      assert_match("Size #{size} text", output)
      assert_match(/text-#{if size == 3
                             "base"
                           elsif size == 1
                             "xs"
                           elsif size == 2
                             "sm"
                           else
                             ["lg", "xl", "2xl", "3xl", "4xl", "5xl"][size - 4]
                           end}/, output)
    end
  end

  def test_text_with_weights
    %w[light regular medium bold].each do |weight|
      output = phlex_context do
        RubyUI::Text(weight: weight) { "#{weight.capitalize} text" }
      end

      assert_match("#{weight.capitalize} text", output)
      assert_match(/font-#{(weight == "regular") ? "normal" : weight}/, output)
    end
  end

  def test_text_as_different_elements
    %w[p span div label].each do |element|
      output = phlex_context do
        RubyUI::Text(as: element) { element.capitalize.to_s }
      end

      assert_match(element.capitalize.to_s, output)
      assert_match(/<#{element}/, output)
    end
  end

  def test_lead_text
    output = phlex_context do
      RubyUI::Text(as: "p", size: "5", weight: "medium") { "A modal dialog that interrupts the user." }
    end

    assert_match("A modal dialog that interrupts the user.", output)
    assert_match(/text-xl/, output)
    assert_match(/font-medium/, output)
  end

  def test_large_text
    output = phlex_context do
      RubyUI::Text(size: "5", weight: "semibold") { "Are you sure absolutely sure?" }
    end

    assert_match("Are you sure absolutely sure?", output)
    assert_match(/text-xl/, output)
    assert_match(/font-semibold/, output)
  end

  def test_small_text
    output = phlex_context do
      RubyUI::Text(size: "2", weight: "medium") { "Email address" }
    end

    assert_match("Email address", output)
    assert_match(/text-sm/, output)
    assert_match(/font-medium/, output)
  end

  def test_muted_text
    output = phlex_context do
      RubyUI::Text(size: "2", class: "text-muted-foreground") { "Enter your email address." }
    end

    assert_match("Enter your email address.", output)
    assert_match(/text-sm/, output)
    assert_match(/text-muted-foreground/, output)
  end
end
