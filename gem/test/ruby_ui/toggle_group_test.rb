# frozen_string_literal: true

require "test_helper"

class RubyUI::ToggleGroupTest < ComponentTest
  def test_single_uses_group_role_with_aria_pressed
    output = phlex do
      RubyUI.ToggleGroup(type: :single, name: "align", value: "left") do |g|
        g.ToggleGroupItem(value: "left") { "L" }
        g.ToggleGroupItem(value: "right") { "R" }
      end
    end
    assert_match(/role="group"/, output)
    refute_match(/radio/, output)
    refute_match(/aria-checked/, output)
    assert_match(/<button[^>]*aria-pressed="true"[^>]*data-value="left"/, output)
    assert_match(/<button[^>]*aria-pressed="false"[^>]*data-value="right"/, output)
  end

  def test_emits_shadcn_data_attributes
    output = phlex do
      RubyUI.ToggleGroup(type: :multiple, variant: :outline, size: :sm, value: %w[a]) do |g|
        g.ToggleGroupItem(value: "a") { "A" }
        g.ToggleGroupItem(value: "b") { "B" }
      end
    end
    assert_match(/<div[^>]*data-slot="toggle-group"/, output)
    assert_match(/<div[^>]*data-variant="outline"[^>]*data-size="sm"[^>]*data-spacing="2"[^>]*data-orientation="horizontal"/, output)
    assert_match(/<div[^>]*data-multiple/, output)
    assert_equal 2, output.scan('data-slot="toggle-group-item"').size
    assert_match(/<button[^>]*data-variant="outline"[^>]*data-size="sm"[^>]*data-spacing="2"/, output)
    # data-action contains "->", so count attributes instead of matching across the tag
    assert_equal 1, output.scan('data-pressed=""').size
  end

  def test_disabled_group_and_items_carry_data_disabled
    output = phlex do
      RubyUI.ToggleGroup(type: :single, disabled: true) do |g|
        g.ToggleGroupItem(value: "a") { "A" }
      end
    end
    assert_match(/<div[^>]*data-disabled/, output)
    assert_equal 2, output.scan('data-disabled=""').size
  end

  def test_item_level_disabled
    output = phlex do
      RubyUI.ToggleGroup(type: :single) do |g|
        g.ToggleGroupItem(value: "a", disabled: true) { "A" }
        g.ToggleGroupItem(value: "b") { "B" }
      end
    end
    assert_equal 1, output.scan(/<button[^>]*disabled/).size
  end

  def test_default_spacing_is_two
    output = phlex do
      RubyUI.ToggleGroup(type: :single) do |g|
        g.ToggleGroupItem(value: "a") { "A" }
      end
    end
    assert_match(/data-spacing="2"/, output)
    assert_match(/gap-2/, output)
    refute_match(/rounded-none/, output)
  end

  def test_loop_focus_and_orientation_values
    output = phlex do
      RubyUI.ToggleGroup(type: :single, orientation: :vertical, loop_focus: false) do |g|
        g.ToggleGroupItem(value: "a") { "A" }
      end
    end
    assert_match(/data-ruby-ui--toggle-group-loop-focus-value="false"/, output)
    assert_match(/data-ruby-ui--toggle-group-orientation-value="vertical"/, output)
  end

  def test_items_keep_size_min_width_and_padding
    output = phlex do
      RubyUI.ToggleGroup(type: :single) do |g|
        g.ToggleGroupItem(value: "a") { "A" }
      end
    end
    assert_match(/min-w-9/, output)
    refute_match(/min-w-0/, output)
    refute_match(/px-3/, output)
    assert_match(/data-\[state=on\]:bg-muted/, output)
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
    # right item is pressed — assert both attributes appear (they are on the same button element)
    assert_match(/data-value="right"/, output)
    assert_match(/aria-pressed="true"/, output)
    assert_match(/data-state="on"[^>]*data-value="right"|data-value="right"[^>]*data-state="on"/, output)
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

  def test_multiple_roving_tabindex
    output = phlex do
      RubyUI.ToggleGroup(type: :multiple, value: %w[b]) do |g|
        g.ToggleGroupItem(value: "a") { "A" }
        g.ToggleGroupItem(value: "b") { "B" }
      end
    end
    assert_equal 1, output.scan('tabindex="0"').size
    assert_match(/tabindex="0"[^>]*data-value="b"|data-value="b"[^>]*tabindex="0"/, output)
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

  def test_joined_items_have_first_last_rounded
    output = phlex do
      RubyUI.ToggleGroup(type: :single, name: "x", spacing: 0) do |g|
        g.ToggleGroupItem(value: "a") { "A" }
        g.ToggleGroupItem(value: "b") { "B" }
      end
    end
    assert_match(/rounded-none/, output)
    assert_match(/px-2/, output)
    assert_match(/first-of-type:rounded-l-md/, output)
    assert_match(/last-of-type:rounded-r-md/, output)
  end

  def test_spacing_adds_gap_class
    output = phlex do
      RubyUI.ToggleGroup(type: :single, name: "x", spacing: 2) do |g|
        g.ToggleGroupItem(value: "a") { "A" }
        g.ToggleGroupItem(value: "b") { "B" }
      end
    end
    assert_match(/gap-2/, output)
    refute_match(/rounded-none/, output)
  end

  def test_vertical_orientation
    output = phlex do
      RubyUI.ToggleGroup(type: :single, name: "x", orientation: :vertical, spacing: 0) do |g|
        g.ToggleGroupItem(value: "a") { "A" }
        g.ToggleGroupItem(value: "b") { "B" }
      end
    end
    assert_match(/flex-col/, output)
    assert_match(/first-of-type:rounded-t-md/, output)
  end

  def test_outline_joined_adds_shadow_xs
    output = phlex do
      RubyUI.ToggleGroup(type: :single, name: "x", variant: :outline, spacing: 0) do |g|
        g.ToggleGroupItem(value: "a") { "A" }
      end
    end
    assert_match(/shadow-xs/, output)
    assert_match(/border-l-0/, output)
    assert_match(/first-of-type:border-l/, output)
  end

  def test_invalid_orientation_raises
    assert_raises(ArgumentError) do
      phlex do
        RubyUI.ToggleGroup(type: :single, name: "x", orientation: :diagonal) do |g|
          g.ToggleGroupItem(value: "a") { "A" }
        end
      end
    end
  end
end
