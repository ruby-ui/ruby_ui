# frozen_string_literal: true

require "test_helper"

class RubyUI::ToggleGroupTest < ComponentTest
  def test_single_uses_radiogroup_role
    output = phlex do
      RubyUI.ToggleGroup(type: :single, name: "align") do |g|
        g.ToggleGroupItem(value: "left") { "L" }
        g.ToggleGroupItem(value: "right") { "R" }
      end
    end
    assert_match(/role="radiogroup"/, output)
    assert_match(/role="radio"/, output)
  end

  def test_multiple_uses_group_role_with_aria_pressed
    output = phlex do
      RubyUI.ToggleGroup(type: :multiple, name: "fmt") do |g|
        g.ToggleGroupItem(value: "bold") { "B" }
        g.ToggleGroupItem(value: "italic") { "I" }
      end
    end
    assert_match(/role="group"/, output)
    assert_match(/aria-pressed=/, output)
    refute_match(/role="radio"/, output)
  end

  def test_single_initial_value_sets_pressed_item
    output = phlex do
      RubyUI.ToggleGroup(type: :single, name: "align", value: "right") do |g|
        g.ToggleGroupItem(value: "left") { "L" }
        g.ToggleGroupItem(value: "right") { "R" }
      end
    end
    # right item is pressed
    assert_match(/data-value="right"[^>]*aria-checked="true"|aria-checked="true"[^>]*data-value="right"/, output)
    # exactly one hidden input with selected value
    assert_match(/<input[^>]*type="hidden"[^>]*name="align"[^>]*value="right"/, output)
  end

  def test_multiple_initial_value_array_pressed
    output = phlex do
      RubyUI.ToggleGroup(type: :multiple, name: "fmt", value: %w[bold italic]) do |g|
        g.ToggleGroupItem(value: "bold") { "B" }
        g.ToggleGroupItem(value: "italic") { "I" }
        g.ToggleGroupItem(value: "underline") { "U" }
      end
    end
    assert_match(/<input[^>]*name="fmt\[\]"[^>]*value="bold"/, output)
    assert_match(/<input[^>]*name="fmt\[\]"[^>]*value="italic"/, output)
    refute_match(/<input[^>]*name="fmt\[\]"[^>]*value="underline"/, output)
  end

  def test_single_roving_tabindex
    output = phlex do
      RubyUI.ToggleGroup(type: :single, name: "align", value: "left") do |g|
        g.ToggleGroupItem(value: "left") { "L" }
        g.ToggleGroupItem(value: "right") { "R" }
      end
    end
    assert_equal 1, output.scan('tabindex="0"').size
    assert_match(/tabindex="-1"/, output)
  end

  def test_disabled_group_disables_all_items
    output = phlex do
      RubyUI.ToggleGroup(type: :multiple, name: "fmt", disabled: true) do |g|
        g.ToggleGroupItem(value: "bold") { "B" }
        g.ToggleGroupItem(value: "italic") { "I" }
      end
    end
    assert_equal 2, output.scan(/<button[^>]*disabled/).size
  end

  def test_group_controller_attached
    output = phlex do
      RubyUI.ToggleGroup(type: :single, name: "align") do |g|
        g.ToggleGroupItem(value: "left") { "L" }
      end
    end
    assert_match(/data-controller="[^"]*ruby-ui--toggle-group/, output)
    assert_match(/data-ruby-ui--toggle-group-type-value="single"/, output)
    assert_match(/data-ruby-ui--toggle-group-name-value="align"/, output)
  end

  def test_group_items_dont_have_standalone_toggle_controller
    output = phlex do
      RubyUI.ToggleGroup(type: :single, name: "align") do |g|
        g.ToggleGroupItem(value: "left") { "L" }
      end
    end
    # group controller present on wrapper, but item buttons should not be tagged with single-toggle controller
    refute_match(/<button[^>]*data-controller="[^"]*ruby-ui--toggle"/, output)
  end
end
