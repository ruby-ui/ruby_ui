# frozen_string_literal: true

require "test_helper"

class RubyUI::MessageScrollerTest < ComponentTest
  def test_renders_full_structure
    output = phlex do
      RubyUI.MessageScrollerProvider do
        RubyUI.MessageScroller do
          RubyUI.MessageScrollerViewport do
            RubyUI.MessageScrollerContent do
              RubyUI.MessageScrollerItem { "row" }
            end
          end
          RubyUI.MessageScrollerButton
        end
      end
    end

    assert_match(/data-controller="ruby-ui--message-scroller"/, output)
    assert_match(/data-slot="message-scroller"/, output)
    assert_match(/data-slot="message-scroller-viewport"/, output)
    assert_match(/data-slot="message-scroller-content"/, output)
    assert_match(/data-slot="message-scroller-item"/, output)
    assert_match(/data-slot="message-scroller-button"/, output)
  end

  def test_provider_values_default
    output = phlex { RubyUI.MessageScrollerProvider { "x" } }

    assert_match(/message-scroller-auto-scroll-value="false"/, output)
    assert_match(/message-scroller-default-position-value="end"/, output)
    assert_match(/message-scroller-scroll-edge-threshold-value="8"/, output)
    assert_match(/message-scroller-previous-item-peek-value="64"/, output)
    assert_match(/message-scroller-scroll-margin-value="0"/, output)
    refute_match(/preserve-on-prepend-value/, output)
  end

  def test_provider_values_custom
    output = phlex do
      RubyUI.MessageScrollerProvider(auto_scroll: true, previous_item_peek: 32, default_position: :last_anchor,
        scroll_edge_threshold: 16, scroll_margin: 12) { "x" }
    end

    assert_match(/message-scroller-auto-scroll-value="true"/, output)
    assert_match(/message-scroller-previous-item-peek-value="32"/, output)
    assert_match(/message-scroller-default-position-value="last-anchor"/, output)
    assert_match(/message-scroller-scroll-edge-threshold-value="16"/, output)
    assert_match(/message-scroller-scroll-margin-value="12"/, output)
  end

  def test_provider_preserve_on_prepend_is_deprecated
    output = nil
    _, err = capture_io do
      Warning[:deprecated] = true
      output = phlex { RubyUI.MessageScrollerProvider(preserve_on_prepend: false) { "x" } }
    end

    assert_match(/preserve_on_prepend:` is deprecated/, err)
    assert_match(/message-scroller-preserve-on-prepend-value="false"/, output)
  end

  def test_viewport_is_a_named_region_pending_first_scroll
    output = phlex { RubyUI.MessageScrollerViewport { "x" } }

    assert_match(/role="region"/, output)
    assert_match(/aria-label="Messages"/, output)
    assert_match(/tabindex="0"/, output)
    assert_match(/data-pending-scroll=""/, output)
    assert_match(/scroll-fade-b scrollbar-thin scrollbar-gutter-stable/, output)
    refute_match(/overflow-anchor/, output)
  end

  def test_viewport_without_prepend_preservation
    output = phlex { RubyUI.MessageScrollerViewport(preserve_scroll_on_prepend: false) { "x" } }

    assert_match(/\[overflow-anchor:none\]/, output)
  end

  def test_content_live_region_and_spacer
    output = phlex { RubyUI.MessageScrollerContent(spacer_class: "bg-muted") { "x" } }

    assert_match(/role="log"/, output)
    assert_match(/aria-relevant="additions"/, output)
    assert_match(/x<div aria-hidden="true" hidden class="bg-muted" data-message-scroller-spacer=""/, output)
    assert_match(/message-scroller-target="spacer"/, output)
  end

  def test_item_scroll_anchor_and_message_id
    output = phlex do
      RubyUI.MessageScrollerItem(scroll_anchor: true, message_id: "m1") { "row" }
    end

    assert_match(/data-scroll-anchor="true"/, output)
    assert_match(/data-message-id="m1"/, output)
    assert_match(/\[content-visibility:auto\]/, output)
  end

  def test_item_without_anchor
    output = phlex { RubyUI.MessageScrollerItem { "row" } }

    assert_match(/data-scroll-anchor="false"/, output)
  end

  def test_button_targets_and_action
    output = phlex { RubyUI.MessageScrollerButton }

    assert_match(/message-scroller-target="button"/, output)
    assert_match(/click->ruby-ui--message-scroller#jump/, output)
    assert_match(/data-direction="end"/, output)
    assert_match(/message-scroller-direction-param="end"/, output)
    assert_match(/message-scroller-behavior-param="smooth"/, output)
    assert_match(/ inert /, output)
    assert_match(/aria-hidden="true"/, output)
    assert_match(/Scroll to end/, output)
  end

  def test_button_looks_like_secondary_icon_sm_button
    output = phlex { RubyUI.MessageScrollerButton }

    assert_match(/data-variant="secondary"/, output)
    assert_match(/data-size="icon-sm"/, output)
    assert_match(/rounded-\[min\(var\(--radius-md\),10px\)\]/, output)
    assert_match(/bg-background/, output)
    refute_match(/rounded-full|shadow-sm| bg-secondary /, output)
  end

  def test_button_start_direction_and_behavior
    output = phlex { RubyUI.MessageScrollerButton(direction: :start, behavior: :auto, variant: :outline) }

    assert_match(/data-direction="start"/, output)
    assert_match(/message-scroller-behavior-param="auto"/, output)
    assert_match(/data-variant="outline"/, output)
    assert_match(/Scroll to start/, output)
  end
end
