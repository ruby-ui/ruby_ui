# frozen_string_literal: true

require "test_helper"

class RubyUI::ToggleGroupTest < ComponentTest
  LEFT_RIGHT = %(<%= g.ToggleGroupItem(value: "left") { "L" } %><%= g.ToggleGroupItem(value: "right") { "R" } %>)
  BOLD_ITALIC = %(<%= g.ToggleGroupItem(value: "bold") { "B" } %><%= g.ToggleGroupItem(value: "italic") { "I" } %>)
  A_B = %(<%= g.ToggleGroupItem(value: "a") { "A" } %><%= g.ToggleGroupItem(value: "b") { "B" } %>)
  ONLY_A = %(<%= g.ToggleGroupItem(value: "a") { "A" } %>)

  def test_single_uses_radiogroup_role
    output = group(%(type: :single, name: "align"), LEFT_RIGHT)
    assert_match(/role="radiogroup"/, output)
    assert_match(/role="radio"/, output)
  end

  def test_multiple_uses_group_role_with_aria_pressed
    output = group(%(type: :multiple, name: "fmt"), BOLD_ITALIC)
    assert_match(/role="group"/, output)
    assert_match(/aria-pressed=/, output)
    refute_match(/role="radio"/, output)
  end

  def test_single_initial_value_sets_pressed_item
    output = group(%(type: :single, name: "align", value: "right"), LEFT_RIGHT)
    # right item is pressed — assert both attributes appear (they are on the same button element)
    assert_match(/data-value="right"/, output)
    assert_match(/aria-checked="true"/, output)
    assert_match(/data-state="on"[^>]*data-value="right"|data-value="right"[^>]*data-state="on"/, output)
    # exactly one hidden input with selected value
    assert_match(/<input[^>]*type="hidden"[^>]*name="align"[^>]*value="right"/, output)
  end

  def test_multiple_initial_value_array_pressed
    output = group(%(type: :multiple, name: "fmt", value: %w[bold italic]), %(#{BOLD_ITALIC}<%= g.ToggleGroupItem(value: "underline") { "U" } %>))
    assert_match(/<input[^>]*name="fmt\[\]"[^>]*value="bold"/, output)
    assert_match(/<input[^>]*name="fmt\[\]"[^>]*value="italic"/, output)
    refute_match(/<input[^>]*name="fmt\[\]"[^>]*value="underline"/, output)
  end

  def test_single_roving_tabindex
    output = group(%(type: :single, name: "align", value: "left"), LEFT_RIGHT)
    assert_equal 1, output.scan('tabindex="0"').size
    assert_match(/tabindex="-1"/, output)
  end

  def test_disabled_group_disables_all_items
    output = group(%(type: :multiple, name: "fmt", disabled: true), BOLD_ITALIC)
    assert_equal 2, output.scan(/<button[^>]*disabled/).size
  end

  def test_group_controller_attached
    output = group(%(type: :single, name: "align"), %(<%= g.ToggleGroupItem(value: "left") { "L" } %>))
    assert_match(/data-controller="[^"]*ruby-ui--toggle-group/, output)
    assert_match(/data-ruby-ui--toggle-group-type-value="single"/, output)
    assert_match(/data-ruby-ui--toggle-group-name-value="align"/, output)
  end

  def test_group_items_dont_have_standalone_toggle_controller
    output = group(%(type: :single, name: "align"), %(<%= g.ToggleGroupItem(value: "left") { "L" } %>))
    # group controller present on wrapper, but item buttons should not be tagged with single-toggle controller
    refute_match(/<button[^>]*data-controller="[^"]*ruby-ui--toggle"/, output)
  end

  def test_joined_items_have_first_last_rounded
    output = group(%(type: :single, name: "x"), A_B)
    assert_match(/rounded-none/, output)
    assert_match(/first-of-type:rounded-l-md/, output)
    assert_match(/last-of-type:rounded-r-md/, output)
  end

  def test_spacing_adds_gap_class
    output = group(%(type: :single, name: "x", spacing: 2), A_B)
    assert_match(/gap-2/, output)
    refute_match(/rounded-none/, output)
  end

  def test_vertical_orientation
    output = group(%(type: :single, name: "x", orientation: :vertical), A_B)
    assert_match(/flex-col/, output)
    assert_match(/first-of-type:rounded-t-md/, output)
  end

  def test_outline_joined_adds_shadow_xs
    output = group(%(type: :single, name: "x", variant: :outline), ONLY_A)
    assert_match(/shadow-xs/, output)
    assert_match(/border-l-0/, output)
    assert_match(/first-of-type:border-l/, output)
  end

  def test_invalid_orientation_raises
    assert_raises(ArgumentError) { RubyUI::ToggleGroup.new(type: :single, name: "x", orientation: :diagonal) }
  end

  # 2.0: every enumerated argument accepts its String form (spec decision B).
  def test_variant_and_size_accept_the_string_form_through_the_items
    assert_equal group(%(variant: :outline, size: :sm), ONLY_A), group(%(variant: "outline", size: "sm"), ONLY_A)
  end

  def test_type_accepts_the_string_form
    assert_equal group(%(type: :multiple, name: "fmt", value: %w[bold]), BOLD_ITALIC),
      group(%(type: "multiple", name: "fmt", value: %w[bold]), BOLD_ITALIC)
  end

  def test_orientation_accepts_the_string_form
    assert_equal group(%(type: :single, name: "x", orientation: :vertical), A_B),
      group(%(type: :single, name: "x", orientation: "vertical"), A_B)
  end

  def test_an_items_variant_and_size_override_accept_the_string_form
    symbols = group(%(type: :single, name: "x"), %(<%= g.ToggleGroupItem(value: "a", variant: :outline, size: :lg) { "A" } %>))
    strings = group(%(type: :single, name: "x"), %(<%= g.ToggleGroupItem(value: "a", variant: "outline", size: "lg") { "A" } %>))
    assert_equal symbols, strings
    assert_match(/h-10/, strings)
  end

  private

  # A group with the given constructor arguments around the given items.
  def group(args, items)
    erb(%(<%= render RubyUI::ToggleGroup.new(#{args}) do |g| %>#{items}<% end %>))
  end
end
