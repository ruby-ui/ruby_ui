# frozen_string_literal: true

require "test_helper"

class RubyUI::SheetTest < ComponentTest
  def test_render_with_all_items
    output = phlex do
      RubyUI.Sheet do
        RubyUI.SheetTrigger do
          RubyUI.Button(variant: :outline) { "Open Sheet" }
        end

        RubyUI.SheetContent(class: "sm:max-w-sm") do
          RubyUI.SheetHeader do
            RubyUI.SheetTitle { "Edit profile" }
            RubyUI.SheetDescription { "Make changes to your profile here. Click save when you're done." }
          end
          RubyUI.SheetMiddle do
            RubyUI.Input(placeholder: "Joel Drapper") { "Joel Drapper" }
            RubyUI.Input(placeholder: "joel@drapper.me")

            RubyUI.SheetFooter do
              RubyUI.Button(variant: :outline, data: {action: "click->ruby-ui--sheet-content#close"}) { "Cancel" }
              RubyUI.Button(type: "submit") { "Save" }
            end
          end
        end
      end
    end

    assert_match(/Open Sheet/, output)
  end

  def test_render_closed_by_default
    output = phlex { RubyUI.Sheet { "content" } }

    assert_match(/data-ruby-ui--sheet-open-value="false"/, output)
  end

  def test_render_open_when_open_is_true
    output = phlex { RubyUI.Sheet(open: true) { "content" } }

    assert_match(/data-ruby-ui--sheet-open-value="true"/, output)
  end

  # Removal lands a frame after the animation ends; without a forwards fill mode that frame flashes.
  def test_content_and_backdrop_hold_the_last_frame_of_the_exit_animation
    output = phlex do
      RubyUI.SheetContent { "sheet body" }
    end

    assert_equal 2, output.scan("data-[state=closed]:fill-mode-forwards").size
  end

  # Every modal shares shadcn's overlay: black at 10% in both themes, blurred only where backdrop-filter is supported.
  def test_backdrop_uses_the_shared_modal_overlay
    output = phlex do
      RubyUI.SheetContent { "sheet body" }
    end

    assert_includes output, "bg-black/10"
    assert_includes output, "supports-backdrop-filter:backdrop-blur-xs"
    refute_match(/bg-background\/80|bg-black\/80|backdrop-blur-sm/, output)
  end
end
