# frozen_string_literal: true

require "test_helper"

class RubyUI::SelectTest < ComponentTest
  def render_select(trigger: {}, content: {}, item: {})
    phlex do
      RubyUI.Select do
        RubyUI.SelectInput(name: "fruit", required: true)
        RubyUI.SelectTrigger(**trigger) do
          RubyUI.SelectValue(placeholder: "Select a fruit")
        end
        RubyUI.SelectContent(**content) do
          RubyUI.SelectGroup do
            RubyUI.SelectLabel { "Fruits" }
            RubyUI.SelectItem(value: "apple", **item) { "Apple" }
            RubyUI.SelectItem(value: "banana") { "Banana" }
          end
        end
      end
    end
  end

  def test_render_with_all_items
    output = render_select

    assert_match(/Apple/, output)
    assert_match('name="fruit"', output)
    assert_match('data-controller="ruby-ui--select"', output)
  end

  # Base UI's hidden input: still validated (required), but out of sight,
  # the tab order and the accessibility tree.
  def test_input_is_hidden_but_validatable
    output = render_select
    input = output[/<input(?:[^>"]|"[^"]*")*>/]

    assert_match('class="sr-only"', input)
    assert_match('aria-hidden="true"', input)
    assert_match('tabindex="-1"', input)
    assert_match("required", input)
    refute_match('type="hidden"', input)
  end

  def test_trigger_is_a_combobox_without_controls_while_closed
    trigger = render_select[/<button(?:[^>"]|"[^"]*")*>/]

    assert_match('role="combobox"', trigger)
    assert_match('aria-haspopup="listbox"', trigger)
    assert_match('aria-expanded="false"', trigger)
    assert_match('data-slot="select-trigger"', trigger)
    assert_match('data-size="default"', trigger)
    refute_match("aria-controls", trigger)
    refute_match("aria-activedescendant", trigger)
  end

  def test_trigger_sizes
    assert_match('data-size="sm"', render_select(trigger: {size: :sm})[/<button(?:[^>"]|"[^"]*")*>/])
    assert_match('data-size="default"', render_select(trigger: {size: :huge})[/<button(?:[^>"]|"[^"]*")*>/])
  end

  def test_trigger_icon_is_hidden_from_assistive_tech
    output = render_select

    assert_match(/<svg[^>]*aria-hidden="true"[^>]*text-muted-foreground/, output)
  end

  def test_content_is_a_listbox_popover_without_animation
    content = render_select[/<div(?:[^>"]|"[^"]*")*data-slot="select-content"(?:[^>"]|"[^"]*")*>/]

    assert_match('role="listbox"', content)
    assert_match('popover="manual"', content)
    assert_match('data-side="bottom"', content)
    assert_match('data-align="center"', content)
    assert_match('data-side-offset="4"', content)
    refute_match("animate-", content)
  end

  def test_content_placement_props
    content = render_select(content: {side: :top, align: :start, side_offset: 8, align_offset: 2})[/<div(?:[^>"]|"[^"]*")*data-slot="select-content"(?:[^>"]|"[^"]*")*>/]

    assert_match('data-side="top"', content)
    assert_match('data-align="start"', content)
    assert_match('data-side-offset="8"', content)
    assert_match('data-align-offset="2"', content)
  end

  def test_content_ignores_outlet_id
    output = phlex { RubyUI.SelectContent(outlet_id: "fruit") { "options" } }

    refute_match("outlet", output)
  end

  def test_group_is_labelled_by_its_label
    output = render_select
    group_id = output[/role="group"[^>]*aria-labelledby="([^"]+)"/, 1] || output[/aria-labelledby="([^"]+)"[^>]*role="group"/, 1]

    assert group_id, "group should be aria-labelledby its label"
    assert_match(/<div[^>]*id="#{group_id}"[^>]*>Fruits<\/div>/, output)
    refute_match("<h3", output)
  end

  def test_label_outside_a_group_has_no_id_and_stays_visible_to_assistive_tech
    output = phlex { RubyUI.SelectLabel { "Fruits" } }

    refute_match("id=", output)
    refute_match("aria-hidden", output)
  end

  def test_only_the_naming_label_is_hidden
    output = phlex do
      RubyUI.SelectGroup do
        RubyUI.SelectLabel { "Fruits" }
        RubyUI.SelectLabel { "More" }
      end
    end

    assert_match(/<div[^>]*aria-hidden="true"[^>]*>Fruits<\/div>/, output)
    refute_match(/aria-hidden="true"[^>]*>More/, output)
  end

  def test_trigger_height_is_overridable
    trigger = render_select(trigger: {class: "h-10"})[/<button(?:[^>"]|"[^"]*")*>/]

    assert_match("h-10", trigger)
    refute_match(/\bh-9\b/, trigger)
  end

  def test_trigger_size_nil_falls_back_to_default
    assert_match('data-size="default"', render_select(trigger: {size: nil})[/<button(?:[^>"]|"[^"]*")*>/])
  end

  def test_item_is_a_roving_option_with_the_indicator_on_the_right
    item = render_select[/<div(?:[^>"]|"[^"]*")*role="option"(?:[^>"]|"[^"]*")*>/]

    assert_match('tabindex="-1"', item)
    assert_match('aria-selected="false"', item)
    assert_match('data-value="apple"', item)
    assert_match("pr-8", item)
    assert_match(/absolute right-2/, render_select)
  end

  def test_disabled_item
    item = render_select(item: {disabled: true})[/<div(?:[^>"]|"[^"]*")*role="option"(?:[^>"]|"[^"]*")*>/]

    assert_match('aria-disabled="true"', item)
    assert_match("data-disabled", item)
  end

  def test_select_value_renders_placeholder_when_block_returns_nil
    output = phlex do
      RubyUI.SelectValue(placeholder: "Placeholder") do
        nil
      end
    end

    assert_match(/Placeholder/, output)
    assert_match('data-placeholder-text="Placeholder"', output)
  end
end
