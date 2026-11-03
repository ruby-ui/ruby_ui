# frozen_string_literal: true

require "test_helper"

class RubyUI::HoverCardTest < ComponentTest
  def test_render_with_all_items
    output = phlex do
      RubyUI.HoverCard do
        RubyUI.HoverCardTrigger do
          RubyUI.Button(variant: :link) { "@joeldrapper" }
        end
        RubyUI.HoverCardContent do |card_content|
          card_content.div(class: "flex justify-between space-x-4") do
            RubyUI.Avatar do
              RubyUI.AvatarImage(src: "https://avatars.githubusercontent.com/u/246692?v=4", alt: "joeldrapper")
              RubyUI.AvatarFallback { "JD" }
            end
          end
        end
      end
    end

    assert_match(/joeldrapper/, output)
  end

  def test_parts_carry_shadcn_data_slots
    output = phlex do
      RubyUI.HoverCard do
        RubyUI.HoverCardTrigger { "trigger" }
        RubyUI.HoverCardContent { "card body" }
      end
    end

    assert_match(/data-slot="hover-card"/, output)
    assert_match(/data-slot="hover-card-trigger"/, output)
    assert_match(/data-slot="hover-card-content"/, output)
  end

  # The card is a native popover: the top layer keeps overflow-hidden
  # ancestors from clipping it, and the UA hides it while closed.
  def test_content_is_a_manual_popover_that_starts_closed
    output = phlex { RubyUI.HoverCardContent { "card body" } }

    refute_match(/<template/, output)
    assert_match(/popover="manual"/, output)
    assert_match(/data-state="closed"/, output)
    assert_match(/data-closed=""/, output)
    refute_match(/[\s"]hidden[\s"=]/, output)
  end

  def test_content_uses_the_vega_classes
    output = phlex { RubyUI.HoverCardContent { "card body" } }

    %w[w-64 rounded-lg ring-1 ring-foreground/10 bg-popover text-popover-foreground text-sm p-4 shadow-md duration-100 origin-(--transform-origin)].each do |token|
      assert_includes output, token
    end
    refute_match(/\bborder\b(?!-0)/, output)
  end

  def test_content_placement_defaults_match_shadcn
    output = phlex { RubyUI.HoverCardContent { "card body" } }

    assert_match(/data-side-offset="4"/, output)
    assert_match(/data-align-offset="4"/, output)
    # No side/align given: the controller falls back to option placement:, then bottom/center.
    refute_match(/data-preferred-side/, output)
    refute_match(/data-preferred-align/, output)
  end

  def test_content_takes_side_align_and_offsets
    output = phlex { RubyUI.HoverCardContent(side: :top, align: :start, side_offset: 8, align_offset: 0) { "card" } }

    assert_match(/data-preferred-side="top"/, output)
    assert_match(/data-preferred-align="start"/, output)
    assert_match(/data-side-offset="8"/, output)
    assert_match(/data-align-offset="0"/, output)
  end

  def test_content_ignores_unknown_side_and_align
    output = phlex { RubyUI.HoverCardContent(side: :middle, align: :around) { "card" } }

    refute_match(/data-preferred-side/, output)
    refute_match(/data-preferred-align/, output)
  end

  def test_trigger_takes_delays
    output = phlex { RubyUI.HoverCardTrigger(delay: 100, close_delay: 50) { "trigger" } }

    assert_match(/data-delay="100"/, output)
    assert_match(/data-close-delay="50"/, output)
  end

  # Without delay:/close_delay: the controller uses option delay:, then Base UI's 600/300.
  def test_trigger_without_delays_renders_no_delay_attributes
    output = phlex { RubyUI.HoverCardTrigger { "trigger" } }

    refute_match(/data-delay=/, output)
    refute_match(/data-close-delay=/, output)
  end

  def test_root_is_closed_by_default
    output = phlex { RubyUI.HoverCard { "card" } }

    assert_match(/data-ruby-ui--hover-card-open-value="false"/, output)
  end

  def test_root_can_start_open
    output = phlex { RubyUI.HoverCard(open: true) { "card" } }

    assert_match(/data-ruby-ui--hover-card-open-value="true"/, output)
  end

  # option: is the older API; it still reaches the controller as a fallback.
  def test_root_passes_the_legacy_options_through
    output = phlex { RubyUI.HoverCard(option: {placement: "top-start", delay: [100, 50]}) { "card" } }

    assert_match(/&quot;placement&quot;:&quot;top-start&quot;/, output)
    assert_match(/&quot;delay&quot;:\[100,50\]/, output)
  end

  # The exit animation would flash its first frame back before hidePopover() without a forwards fill mode.
  def test_content_holds_the_last_frame_of_the_exit_animation
    output = phlex { RubyUI.HoverCardContent { "card body" } }

    assert_match(/data-closed:fill-mode-forwards/, output)
  end
end
