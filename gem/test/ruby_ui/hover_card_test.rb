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

  # Floating UI positions a real element in the DOM (tippy used to clone a
  # <template>). Content must render as a hidden, positioned div.
  def test_content_renders_hidden_positioned_div_not_template
    output = phlex do
      RubyUI.HoverCardContent { "card body" }
    end

    refute_match(/<template/, output)
    assert_match(/hidden/, output)
    assert_match(/card body/, output)
  end

  # The strategy lives on the root, so the content takes its `position` from
  # the group variant the root switches on.
  def test_content_takes_its_position_from_the_root_strategy
    output = phlex do
      RubyUI.HoverCardContent { "card body" }
    end

    assert_match(%r{group-\[\.is-absolute\]/hover-card:absolute}, output)
    assert_match(%r{group-\[\.is-fixed\]/hover-card:fixed}, output)
  end

  def test_root_is_absolute_by_default
    output = phlex { RubyUI.HoverCard { "card" } }

    assert_match(%r{class="group/hover-card is-absolute"}, output)
  end

  # An ancestor with `overflow: hidden` clips an absolutely positioned card;
  # `strategy: "fixed"` is what lets the card escape it.
  def test_root_opts_into_the_fixed_strategy
    output = phlex { RubyUI.HoverCard(option: {strategy: "fixed"}) { "card" } }

    assert_match(%r{class="group/hover-card is-fixed"}, output)
    assert_match(/&quot;strategy&quot;:&quot;fixed&quot;/, output)
  end

  # Floating UI treats anything but "fixed" as absolute, so the class has to
  # fall back the same way — otherwise a typo renders `fixed` while the
  # positioning engine computes `absolute`.
  def test_root_falls_back_to_absolute_for_an_unsupported_strategy
    output = phlex { RubyUI.HoverCard(option: {strategy: "absolut"}) { "card" } }

    assert_match(%r{class="group/hover-card is-absolute"}, output)
  end

  # `hidden` lands a frame after the animation ends; without a forwards fill mode that frame flashes.
  def test_content_holds_the_last_frame_of_the_exit_animation
    output = phlex do
      RubyUI.HoverCardContent { "card body" }
    end

    assert_match(/data-\[state=closed\]:fill-mode-forwards/, output)
  end
end
