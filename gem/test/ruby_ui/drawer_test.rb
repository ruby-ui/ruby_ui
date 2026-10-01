# frozen_string_literal: true

require "test_helper"

class RubyUI::DrawerTest < ComponentTest
  def test_render_with_all_items
    output = phlex do
      RubyUI.Drawer do
        RubyUI.DrawerTrigger do
          RubyUI.Button(variant: :outline) { "Open Drawer" }
        end

        RubyUI.DrawerContent do
          RubyUI.DrawerHeader do
            RubyUI.DrawerTitle { "Move Goal" }
            RubyUI.DrawerDescription { "Set your daily activity goal." }
          end
          RubyUI.DrawerMiddle { "body" }
          RubyUI.DrawerFooter do
            RubyUI.DrawerClose do
              RubyUI.Button(variant: :outline) { "Cancel" }
            end
          end
        end
      end
    end

    assert_match(/data-controller="ruby-ui--drawer"/, output)
    assert_match(/click->ruby-ui--drawer#open/, output)
    assert_match(/Open Drawer/, output)
    assert_match(/<template data-ruby-ui--drawer-target="content"><dialog/, output)
    assert_match(/data-controller="ruby-ui--drawer-content"/, output)
    assert_match(/<h2 [^>]*data-ruby-ui--drawer-content-target="title"[^>]*>Move Goal<\/h2>/, output)
    assert_match(/<p [^>]*data-ruby-ui--drawer-content-target="description"[^>]*>Set your daily activity goal.<\/p>/, output)
    assert_match(/click->ruby-ui--drawer-content#close/, output)
  end

  def test_render_closed_by_default
    output = phlex { RubyUI.Drawer { "content" } }

    assert_match(/data-ruby-ui--drawer-open-value="false"/, output)
  end

  def test_render_open_when_open_is_true
    output = phlex { RubyUI.Drawer(open: true) { "content" } }

    assert_match(/data-ruby-ui--drawer-open-value="true"/, output)
  end

  def test_default_snap_points
    output = phlex { RubyUI.DrawerContent { "body" } }

    assert_match(/data-ruby-ui--drawer-content-initial-value="0"/, output)
    assert_match(/style="--drawer-band: 60%"/, output)
    assert_match(/style="top: 60%"/, output)
    assert_match(/style="top: 92%"/, output)
  end

  # shadcn's units: up to 1 is a fraction of the viewport, above 1 is pixels, a string passes through.
  def test_snap_points_accept_fractions_pixels_and_css_lengths
    output = phlex { RubyUI.DrawerContent(snap_points: [0.25, 400, "24rem", 1]) { "body" } }

    assert_match(/style="top: 25%"/, output)
    assert_match(/style="top: 400px"/, output)
    assert_match(/style="top: 24rem"/, output)
    assert_match(/style="top: 100%"/, output)
    assert_match(/style="--drawer-band: 25%"/, output)
  end

  def test_snap_points_render_one_marker_each_and_open_at_initial
    output = phlex { RubyUI.DrawerContent(snap_points: [0.35, 0.7, 1], initial: 1) { "body" } }

    assert_equal 3, output.scan("before:snap-start").size
    assert_equal 3, output.scan("drawer-content-target=\"snap\"").size
    assert_match(/style="top: 35%"/, output)
    assert_match(/style="top: 100%"/, output)
    assert_match(/data-ruby-ui--drawer-content-initial-value="1"/, output)
    assert_match(/style="--drawer-band: 70%"/, output)
  end

  # Mirrors the controller: an index outside the list (negative included) opens at the first snap point.
  def test_initial_out_of_range_opens_at_the_first_snap_point
    assert_match(/style="--drawer-band: 40%"/, phlex { RubyUI.DrawerContent(snap_points: [0.4, 0.8], initial: 5) { "body" } })
    assert_match(/style="--drawer-band: 40%"/, phlex { RubyUI.DrawerContent(snap_points: [0.4, 0.8], initial: -1) { "body" } })
  end

  def test_no_snap_points_opens_full_height
    output = phlex { RubyUI.DrawerContent(snap_points: []) { "body" } }

    assert_match(/style="--drawer-band: 100%"/, output)
    refute_match(/before:snap-start/, output)
  end

  def test_panel_carries_the_snap_points_style_hook
    assert_match(/data-snap-points/, phlex { RubyUI.DrawerContent { "body" } })
    refute_match(/data-snap-points/, phlex { RubyUI.DrawerContent(snap_points: []) { "body" } })
  end

  # An autofocus panel wins the dialog's focusing steps, so the first field is left alone.
  def test_initial_focus_false_makes_the_panel_take_focus
    output = phlex { RubyUI.DrawerContent(initial_focus: false) { "body" } }

    assert_match(/<div [^>]*tabindex="-1"[^>]*autofocus/, output)
    refute_match(/autofocus/, phlex { RubyUI.DrawerContent { "body" } })
  end

  def test_modal_renders_a_backdrop_that_holds_the_last_frame_of_its_exit_animation
    output = phlex { RubyUI.DrawerContent { "body" } }

    assert_match(/data-ruby-ui--drawer-content-modal-value="true"/, output)
    assert_match(/data-ruby-ui--drawer-content-target="backdrop"/, output)
    assert_match(/click->ruby-ui--drawer-content#dismiss/, output)
    assert_match(/data-\[state=closed\]:fill-mode-forwards/, output)
    # The controller writes the scrim's opacity per drag frame; a transition would lag it.
    assert_match(/transition-none/, output)
  end

  def test_non_modal_has_no_backdrop
    output = phlex { RubyUI.DrawerContent(modal: false) { "body" } }

    assert_match(/data-ruby-ui--drawer-content-modal-value="false"/, output)
    refute_match(/data-ruby-ui--drawer-content-target="backdrop"/, output)
  end

  def test_dismissible_value
    assert_match(/data-ruby-ui--drawer-content-dismissible-value="true"/, phlex { RubyUI.DrawerContent { "body" } })
    assert_match(/data-ruby-ui--drawer-content-dismissible-value="false"/, phlex { RubyUI.DrawerContent(dismissible: false) { "body" } })
  end

  def test_swipe_handle_is_rendered_by_default_and_can_be_left_out
    with_handle = phlex { RubyUI.DrawerContent { "body" } }
    without_handle = phlex { RubyUI.DrawerContent(handle: false) { "body" } }

    assert_match(/pointerdown->ruby-ui--drawer-content#startDrag/, with_handle)
    refute_match(/startDrag/, without_handle)
  end

  def test_swipe_handle_merges_classes
    output = phlex { RubyUI.DrawerSwipeHandle(class: "w-20 bg-primary") }

    assert_match(/aria-hidden="true"/, output)
    assert_match(/w-20/, output)
    assert_match(/bg-primary/, output)
    refute_match(/w-12/, output)
    refute_match(%r{bg-muted-foreground/40}, output)
  end

  def test_content_attrs_go_to_the_panel
    output = phlex { RubyUI.DrawerContent(class: "max-w-lg", id: "panel") { "body" } }

    assert_match(/<div [^>]*data-ruby-ui--drawer-content-target="panel"[^>]*id="panel"/, output)
    assert_match(/max-w-lg/, output)
  end
end
