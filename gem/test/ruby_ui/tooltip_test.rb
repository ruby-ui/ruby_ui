# frozen_string_literal: true

require "test_helper"

class RubyUI::TooltipTest < ComponentTest
  def test_render_with_all_items
    output = phlex do
      RubyUI.Tooltip do
        RubyUI.TooltipTrigger do
          RubyUI.Button(variant: :outline, icon: true) { "?" }
        end
        RubyUI.TooltipContent do
          RubyUI::Text(as: "p") { "Add to library" }
        end
      end
    end

    assert_match(/Add to library/, output)
  end

  def test_data_slots
    output = phlex do
      RubyUI.Tooltip do
        RubyUI.TooltipTrigger { "Trigger" }
        RubyUI.TooltipContent { "Tip" }
      end
    end

    assert_match(/data-slot="tooltip"/, output)
    assert_match(/data-slot="tooltip-trigger"/, output)
    assert_match(/data-slot="tooltip-content"/, output)
    assert_match(/data-slot="tooltip-arrow"/, output)
  end

  def test_root_values
    output = phlex { RubyUI.Tooltip(open: true, disabled: true, placement: "bottom") { "x" } }

    assert_match(/data-controller="ruby-ui--tooltip"/, output)
    assert_match(/data-ruby-ui--tooltip-open-value="true"/, output)
    assert_match(/data-ruby-ui--tooltip-disabled-value="true"/, output)
    assert_match(/data-ruby-ui--tooltip-placement-value="bottom"/, output)
  end

  # An empty value would read as true in Stimulus.
  def test_root_coerces_nil_to_false
    output = phlex { RubyUI.Tooltip(open: nil, disabled: nil) { "x" } }

    assert_match(/data-ruby-ui--tooltip-open-value="false"/, output)
    assert_match(/data-ruby-ui--tooltip-disabled-value="false"/, output)
  end

  def test_root_defaults_leave_placement_to_the_content
    output = phlex { RubyUI.Tooltip { "x" } }

    assert_match(/data-ruby-ui--tooltip-open-value="false"/, output)
    assert_match(/data-ruby-ui--tooltip-disabled-value="false"/, output)
    refute_match(/placement-value/, output)
  end

  # The wrapper shrinks to the button (hit area and anchor) and carries no
  # stray attributes.
  def test_trigger_is_an_inline_wrapper
    output = phlex { RubyUI.TooltipTrigger { "Trigger" } }

    assert_match(/class="inline-flex w-fit"/, output)
    assert_match(/data-ruby-ui--tooltip-target="trigger"/, output)
    refute_match(/variant=/, output)
    refute_match(/data-action/, output)
  end

  def test_trigger_defaults
    output = phlex { RubyUI.TooltipTrigger { "Trigger" } }

    assert_match(/data-delay="0"/, output)
    assert_match(/data-close-delay="0"/, output)
    assert_match(/data-close-on-click="true"/, output)
  end

  def test_trigger_options
    output = phlex { RubyUI.TooltipTrigger(delay: 300, close_delay: 100, close_on_click: false) { "Trigger" } }

    assert_match(/data-delay="300"/, output)
    assert_match(/data-close-delay="100"/, output)
    assert_match(/data-close-on-click="false"/, output)
  end

  def test_content_is_a_manual_popover_tooltip_in_a_template
    output = phlex { RubyUI.TooltipContent { "Tip" } }

    assert_match(/<template data-ruby-ui--tooltip-target="content"><div/, output)
    assert_match(/popover="manual"/, output)
    assert_match(/role="tooltip"/, output)
    assert_match(/id="tooltip-[0-9a-f]{8}"/, output)
    assert_match(/data-state="closed"/, output)
  end

  def test_content_uses_vega_classes
    output = phlex { RubyUI.TooltipContent { "Tip" } }

    %w[bg-foreground text-background inline-flex items-center gap-1.5 rounded-md px-3 py-1.5 text-xs w-fit max-w-xs
      origin-(--transform-origin) overflow-visible].each do |token|
      assert_includes output.scan(/class="([^"]*)"/).first.first.split, token
    end
    refute_match(/bg-popover|shadow-md|pointer-events-none|text-sm/, output)
  end

  def test_content_placement_defaults
    output = phlex { RubyUI.TooltipContent { "Tip" } }

    assert_match(/data-side-offset="4"/, output)
    assert_match(/data-align-offset="0"/, output)
    refute_match(/data-preferred-side/, output)
    refute_match(/data-preferred-align/, output)
  end

  def test_content_placement_options
    output = phlex { RubyUI.TooltipContent(side: :inline_end, align: :start, side_offset: 8, align_offset: 2) { "Tip" } }

    assert_match(/data-preferred-side="inline-end"/, output)
    assert_match(/data-preferred-align="start"/, output)
    assert_match(/data-side-offset="8"/, output)
    assert_match(/data-align-offset="2"/, output)
  end

  def test_content_ignores_unknown_side_and_align
    output = phlex { RubyUI.TooltipContent(side: :middle, align: :around) { "Tip" } }

    refute_match(/data-preferred-side/, output)
    refute_match(/data-preferred-align/, output)
  end

  def test_arrow_is_hidden_from_assistive_tech
    output = phlex { RubyUI.TooltipContent { "Tip" } }

    assert_match(/<span aria-hidden="true" data-slot="tooltip-arrow"/, output)
    assert_match(/rotate-45/, output)
  end
end
