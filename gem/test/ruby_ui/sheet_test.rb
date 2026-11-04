# frozen_string_literal: true

require "test_helper"

class RubyUI::SheetTest < ComponentTest
  def test_render_with_all_items
    output = phlex do
      RubyUI.Sheet do
        RubyUI.SheetTrigger do
          RubyUI.Button(variant: :outline) { "Open Sheet" }
        end

        RubyUI.SheetContent do
          RubyUI.SheetHeader do
            RubyUI.SheetTitle { "Edit profile" }
            RubyUI.SheetDescription { "Make changes to your profile here. Click save when you're done." }
          end
          RubyUI.SheetMiddle do
            RubyUI.Input(placeholder: "Joel Drapper") { "Joel Drapper" }
          end
          RubyUI.SheetFooter do
            RubyUI.Button(variant: :outline, data: {action: "click->ruby-ui--sheet#dismiss"}) { "Cancel" }
            RubyUI.Button(type: "submit") { "Save" }
          end
        end
      end
    end

    assert_match(/Open Sheet/, output)
    %w[sheet sheet-trigger sheet-content sheet-header sheet-footer sheet-title sheet-description sheet-close].each do |slot|
      assert_includes output, %(data-slot="#{slot}"), "missing data-slot=#{slot}"
    end
  end

  def test_render_closed_by_default
    output = phlex { RubyUI.Sheet { "content" } }

    assert_match(/data-ruby-ui--sheet-open-value="false"/, output)
  end

  def test_render_open_when_open_is_true
    output = phlex { RubyUI.Sheet(open: true) { "content" } }

    assert_match(/data-ruby-ui--sheet-open-value="true"/, output)
  end

  # A native <dialog> rendered in place: no <template> clone into <body>.
  def test_content_is_a_native_dialog_in_place
    output = phlex do
      RubyUI.Sheet do
        RubyUI.SheetContent { "sheet body" }
      end
    end

    assert_match(/<dialog[^>]*data-ruby-ui--sheet-target="content"/, output)
    refute_includes output, "<template"
    assert_includes output, "not-open:hidden"
  end

  def test_trigger_is_a_controller_target
    output = phlex { RubyUI.SheetTrigger { "Open" } }

    assert_includes output, %(data-ruby-ui--sheet-target="trigger")
    assert_includes output, %(data-action="click->ruby-ui--sheet#open")
  end

  def test_title_is_an_h2_target
    output = phlex { RubyUI.SheetTitle { "Edit profile" } }

    assert_match(/<h2[^>]*data-ruby-ui--sheet-target="title"/, output)
    assert_includes output, "font-heading font-medium text-foreground"
  end

  def test_description_is_a_target
    output = phlex { RubyUI.SheetDescription { "Details" } }

    assert_includes output, %(data-ruby-ui--sheet-target="description")
  end

  def test_side_defaults_to_right
    output = phlex { RubyUI.SheetContent { "body" } }

    assert_includes output, %(data-side="right")
    assert_includes output, "w-3/4"
    assert_includes output, "sm:max-w-sm"
    assert_includes output, "border-l"
  end

  def test_each_side_sets_data_side_and_its_edge
    {top: "border-b", right: "border-l", bottom: "border-t", left: "border-r"}.each do |side, border|
      output = phlex { RubyUI.SheetContent(side: side) { "body" } }

      assert_includes output, %(data-side="#{side}")
      assert_includes output, border
      assert_includes output, "slide-in-from-#{side}-10"
    end
  end

  def test_unknown_side_falls_back_to_right
    output = phlex { RubyUI.SheetContent(side: :middle) { "body" } }

    assert_includes output, %(data-side="right")
  end

  # Side classes are plain utilities, so a caller's width wins through tailwind_merge.
  def test_caller_width_replaces_the_default
    output = phlex { RubyUI.SheetContent(class: "w-[300px]") { "body" } }

    assert_includes output, "w-[300px]"
    refute_includes output, "w-3/4"
  end

  def test_close_button_is_shown_by_default
    output = phlex { RubyUI.SheetContent { "body" } }

    assert_includes output, %(data-slot="sheet-close")
    assert_includes output, "click->ruby-ui--sheet#dismiss"
    assert_includes output, %(<span class="sr-only">Close</span>)
  end

  def test_close_button_can_be_hidden
    output = phlex { RubyUI.SheetContent(show_close_button: false) { "body" } }

    refute_includes output, %(data-slot="sheet-close")
  end

  # Old markup calls ruby-ui--sheet-content#close; the shim controller still answers it.
  def test_content_keeps_the_legacy_close_controller
    output = phlex { RubyUI.SheetContent { "body" } }

    assert_match(/data-controller="ruby-ui--sheet-content"/, output)
  end

  # The controller closes the <dialog> when the animation ends; without a forwards fill mode that frame flashes.
  def test_panel_and_backdrop_hold_the_last_frame_of_the_exit_animation
    output = phlex { RubyUI.SheetContent { "sheet body" } }

    assert_includes output, "data-[state=closed]:fill-mode-forwards"
    assert_includes output, "data-[state=closed]:backdrop:fill-mode-forwards"
  end
end
