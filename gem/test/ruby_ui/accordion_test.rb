# frozen_string_literal: true

require "test_helper"

class RubyUI::AccordionTest < ComponentTest
  def render_accordion(**options)
    item_options = options.delete(:item) || {}
    phlex do
      RubyUI.Accordion(**options) do
        RubyUI.AccordionItem(**item_options) do
          RubyUI.AccordionTrigger { "First" }
          RubyUI.AccordionContent { "First content" }
        end
        RubyUI.AccordionItem do
          RubyUI.AccordionTrigger { "Second" }
          RubyUI.AccordionContent { "Second content" }
        end
      end
    end
  end

  def test_items_are_native_details_with_summary_and_heading
    output = render_accordion

    assert_equal 2, output.scan("<details").size
    assert_match(%r{<summary[^>]*data-slot="accordion-trigger"[^>]*><h3>First</h3>}, output)
    assert_match(/data-slot="accordion-content"/, output)
    refute_match(/data-controller/, output)
  end

  def test_single_open_by_default_shares_one_name
    output = render_accordion

    names = output.scan(/<details[^>]*\sname="([^"]+)"/).flatten
    assert_equal 2, names.size
    assert_equal 1, names.uniq.size
    assert_match(/\Aruby-ui-accordion-\h{8}\z/, names.first)
  end

  def test_each_accordion_gets_its_own_name
    output = phlex do
      2.times do
        RubyUI.Accordion do
          RubyUI.AccordionItem { RubyUI.AccordionTrigger { "Item" } }
        end
      end
    end

    assert_equal 2, output.scan(/<details[^>]*\sname="([^"]+)"/).flatten.uniq.size
  end

  def test_multiple_leaves_items_unnamed
    output = render_accordion(multiple: true)

    refute_match(/<details[^>]*name=/, output)
  end

  def test_name_does_not_leak_to_items_outside_the_accordion
    output = phlex do
      RubyUI.Accordion { RubyUI.AccordionItem { RubyUI.AccordionTrigger { "Inside" } } }
      RubyUI.AccordionItem { RubyUI.AccordionTrigger { "Outside" } }
    end

    details = output.scan(%r{<details[^>]*>.*?</details>}m)
    assert_equal 2, details.size
    assert_match(/\A<details[^>]*\sname="[^"]+"/, details.first)
    refute_match(/\A<details[^>]*\sname=/, details.last)
  end

  def test_open_item_renders_open_attribute
    output = render_accordion(item: {open: true})

    assert_equal 1, output.scan(/<details[^>]*\sopen[\s>]/).size
  end

  def test_trigger_heading_level_is_configurable
    output = phlex do
      RubyUI.AccordionItem { RubyUI.AccordionTrigger(level: 2) { "Question" } }
    end

    assert_match(%r{<h2>Question</h2>}, output)
    assert_raises(ArgumentError) { RubyUI::AccordionTrigger.new(level: 7) }
    assert_raises(ArgumentError) { RubyUI::AccordionTrigger.new(level: 3.0) }
  end

  def test_trigger_renders_both_chevrons_hidden_from_assistive_tech
    output = render_accordion

    icons = output.scan(/<svg[^>]*data-slot="accordion-trigger-icon"[^>]*>/)
    assert_equal 4, icons.size
    assert(icons.all? { |svg| svg.include?('aria-hidden="true"') })
  end

  def test_trigger_without_icon
    output = phlex do
      RubyUI.AccordionItem { RubyUI.AccordionTrigger(icon: false) { "Question" } }
    end

    refute_match(/<svg/, output)
  end

  def test_custom_icon_block
    output = phlex do
      RubyUI.AccordionItem do
        RubyUI.AccordionTrigger(icon: false) do |trigger|
          trigger.plain "Question"
          RubyUI.AccordionIcon { "+" }
        end
      end
    end

    assert_match(%r{<span aria-hidden="true"[^>]*>\+</span>}, output)
  end

  def test_disabled_item_takes_trigger_out_of_tab_order
    output = render_accordion(item: {disabled: true})

    triggers = output.scan(/<summary[^>]*>/)
    assert_match(/aria-disabled="true"/, triggers.first)
    assert_match(/tabindex="-1"/, triggers.first)
    refute_match(/aria-disabled="true"/, triggers.last)
  end

  def test_disabled_accordion_disables_every_item_unless_overridden
    output = render_accordion(disabled: true, item: {disabled: false})

    triggers = output.scan(/<summary[^>]*>/)
    refute_match(/aria-disabled="true"/, triggers.first)
    assert_match(/aria-disabled="true"/, triggers.last)
  end

  def test_content_classes_go_to_the_inner_element
    output = phlex do
      RubyUI.AccordionItem { RubyUI.AccordionContent(class: "pb-8") { "Body" } }
    end

    assert_match(%r{<div data-slot="accordion-content" class="text-sm"><div class="pt-0 [^"]*pb-8">Body</div></div>}, output)
  end

  # Issue #168: fields inside a closed item stay in the DOM but out of the
  # rendered tree (the browser skips a closed <details> content for layout and
  # focus); the item is a <details> without `open`.
  def test_closed_item_keeps_content_in_a_closed_details
    output = phlex do
      RubyUI.Accordion do
        RubyUI.AccordionItem do
          RubyUI.AccordionTrigger { "Form section" }
          RubyUI.AccordionContent { "This field is required" }
        end
      end
    end

    assert_match(/This field is required/, output)
    refute_match(/<details[^>]*\sopen[\s>]/, output)
  end
end
