# frozen_string_literal: true

require "test_helper"

class RubyUI::DropdownMenuTest < ComponentTest
  def test_render_with_all_items
    output = phlex do
      RubyUI.DropdownMenu do
        RubyUI.DropdownMenuTrigger(class: "w-full") do
          RubyUI.Button(variant: :outline) { "Open" }
        end
        RubyUI.DropdownMenuContent do
          RubyUI.DropdownMenuLabel { "My Account" }
          RubyUI.DropdownMenuSeparator
          RubyUI.DropdownMenuItem(href: "#") { "Profile" }
          RubyUI.DropdownMenuItem(href: "#") { "Billing" }
          RubyUI.DropdownMenuItem(href: "#") { "Team" }
          RubyUI.DropdownMenuItem(href: "#") { "Subscription" }
        end
      end
    end

    assert_match(/Open/, output)
  end

  def test_render_with_strategy_absolute
    output = phlex do
      RubyUI.DropdownMenu(options: {strategy: "absolute"}) do
        RubyUI.DropdownMenuTrigger(class: "w-full") do
          RubyUI.Button(variant: :outline) { "Open" }
        end
        RubyUI.DropdownMenuContent do
          RubyUI.DropdownMenuLabel { "My Account" }
          RubyUI.DropdownMenuSeparator
          RubyUI.DropdownMenuItem(href: "#") { "Profile" }
          RubyUI.DropdownMenuItem(href: "#") { "Billing" }
          RubyUI.DropdownMenuItem(href: "#") { "Team" }
          RubyUI.DropdownMenuItem(href: "#") { "Subscription" }
        end
      end
    end

    assert_match(/is-absolute/, output)
  end

  def test_render_with_strategy_fixed
    output = phlex do
      RubyUI.DropdownMenu(options: {strategy: "fixed"}) do
        RubyUI.DropdownMenuTrigger(class: "w-full") do
          RubyUI.Button(variant: :outline) { "Open" }
        end
        RubyUI.DropdownMenuContent do
          RubyUI.DropdownMenuLabel { "My Account" }
          RubyUI.DropdownMenuSeparator
          RubyUI.DropdownMenuItem(href: "#") { "Profile" }
          RubyUI.DropdownMenuItem(href: "#") { "Billing" }
          RubyUI.DropdownMenuItem(href: "#") { "Team" }
          RubyUI.DropdownMenuItem(href: "#") { "Subscription" }
        end
      end
    end

    assert_match(/is-fixed/, output)
  end

  # Floating UI treats anything but "fixed" as absolute, so the class has to
  # fall back the same way — otherwise a typo renders `fixed` while the
  # positioning engine computes `absolute`.
  def test_render_with_unsupported_strategy_falls_back_to_absolute
    output = phlex do
      RubyUI.DropdownMenu(options: {strategy: "absolut"}) do
        RubyUI.DropdownMenuTrigger(class: "w-full") do
          RubyUI.Button(variant: :outline) { "Open" }
        end
        RubyUI.DropdownMenuContent do
          RubyUI.DropdownMenuItem(href: "#") { "Profile" }
        end
      end
    end

    assert_match(%r{class="group/dropdown-menu is-absolute"}, output)
  end

  # `hidden` lands a frame after the animation ends; without a forwards fill mode that frame flashes.
  def test_content_holds_the_last_frame_of_the_exit_animation
    output = phlex do
      RubyUI.DropdownMenuContent { "menu body" }
    end

    assert_match(/data-\[state=closed\]:fill-mode-forwards/, output)
  end
end
