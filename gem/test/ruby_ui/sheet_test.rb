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
              RubyUI.SheetClose { RubyUI.Button(variant: :outline) { "Cancel" } }
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

  def test_trigger_has_open_action
    assert_match(/data-action="click->ruby-ui--sheet#open"/, render_sheet)
  end

  # Regression test: content must be a native <dialog>, not a <template> cloned onto <body>
  def test_content_renders_native_dialog
    output = render_sheet

    assert_match(/<dialog\b/, output, "SheetContent must render a native <dialog>")
    refute_match(/<template[\s>]/, output, "SheetContent must not use a <template> element")
  end

  def test_content_is_the_sheet_target_and_carries_the_content_controller
    tag = dialog_tag(render_sheet)

    assert_match(/\sdata-controller="ruby-ui--sheet-content"/, tag)
    assert_match(/\sdata-ruby-ui--sheet-target="dialog"/, tag)
  end

  def test_content_closes_on_backdrop_click
    assert_match(/\sdata-action="click->ruby-ui--sheet-content#backdropClick"/, dialog_tag(render_sheet))
  end

  def test_content_keeps_user_supplied_actions
    tag = dialog_tag(render_content(data: {action: "keydown->form#guard"}))

    assert_match(/data-action="click->ruby-ui--sheet-content#backdropClick keydown->form#guard"/, tag)
  end

  # The controller owns data-state; the closed markup must not start in one
  def test_content_renders_without_data_state
    refute_match(/\sdata-state=/, dialog_tag(render_sheet))
  end

  # A caller's bare `flex` would override the UA `dialog:not([open]) { display: none }`.
  def test_content_stays_hidden_when_closed
    assert_dialog_classes("not-open:hidden", "flex", class: "flex flex-col")
  end

  def test_content_resets_the_ua_dialog_box
    assert_dialog_classes("m-0", "max-w-full", "max-h-full", "text-foreground")
  end

  def test_content_has_enter_and_exit_animations
    assert_dialog_classes(
      "data-[state=open]:animate-in",
      "data-[state=open]:duration-500",
      "data-[state=closed]:animate-out",
      "data-[state=closed]:duration-300",
      "data-[state=closed]:fill-mode-forwards"
    )
  end

  # ::backdrop does not inherit the panel's --tw-duration, so it carries its own exit timing to fade in step.
  def test_content_animates_and_styles_backdrop
    assert_dialog_classes(
      "backdrop:bg-background/80",
      "backdrop:backdrop-blur-sm",
      "data-[state=open]:backdrop:animate-in",
      "data-[state=open]:backdrop:fade-in-0",
      "data-[state=closed]:backdrop:animate-out",
      "data-[state=closed]:backdrop:fade-out-0",
      "data-[state=closed]:backdrop:duration-300",
      "data-[state=closed]:backdrop:fill-mode-forwards"
    )
  end

  # The UA sheet pins a modal <dialog> to every edge (inset: 0); each side must release the opposite one.
  def test_each_side_pins_one_edge
    {
      right: %w[inset-y-0 right-0 left-auto h-full w-3/4 data-[state=open]:slide-in-from-right data-[state=closed]:slide-out-to-right],
      left: %w[inset-y-0 left-0 right-auto h-full w-3/4 data-[state=open]:slide-in-from-left data-[state=closed]:slide-out-to-left],
      top: %w[inset-x-0 top-0 bottom-auto w-full h-auto data-[state=open]:slide-in-from-top data-[state=closed]:slide-out-to-top],
      bottom: %w[inset-x-0 bottom-0 top-auto w-full h-auto data-[state=open]:slide-in-from-bottom data-[state=closed]:slide-out-to-bottom]
    }.each { |side, expected| assert_dialog_classes(*expected, side: side) }
  end

  def test_close_wraps_its_content_with_the_close_action
    output = phlex { RubyUI.SheetClose { RubyUI.Button { "Cancel" } } }

    assert_match(/<div data-action="click->ruby-ui--sheet-content#close"><button/, output)
  end

  def test_close_keeps_user_supplied_actions
    output = phlex { RubyUI.SheetClose(data: {action: "click->form#reset"}) { "Cancel" } }

    assert_match(/data-action="click->ruby-ui--sheet-content#close click->form#reset"/, output)
  end

  def test_close_button_is_rendered_by_default_and_closes
    button = render_sheet[/<button\b[^>]*\sdata-action="click->ruby-ui--sheet-content#close"[^>]*>/].to_s

    refute_empty button, "SheetContent must render the corner close button"
    assert_match(/\stype="button"/, button, "the corner button must not submit a form wrapped around the content")
  end

  def test_close_button_can_be_hidden
    output = render_content(show_close_button: false)

    refute_match(/<button/, output, "show_close_button: false must not render the corner button")
    assert_match(/Content/, output)
  end

  # Lets a caller target one side from the outside, e.g. class: "data-[side=bottom]:max-h-[50vh]"
  def test_content_exposes_its_side
    %i[top right bottom left].each do |side|
      assert_match(/\sdata-side="#{side}"/, dialog_tag(render_content(side: side)))
    end
  end

  def test_left_and_right_have_a_default_width
    %i[left right].each do |side|
      classes = dialog_classes(side: side)

      assert_includes classes, "w-3/4", "side: #{side}"
      assert_includes classes, "sm:max-w-sm", "side: #{side}"
    end
  end

  def test_a_caller_can_override_the_default_width
    classes = dialog_classes(class: "w-[300px] sm:max-w-lg")

    refute_includes classes, "w-3/4"
    refute_includes classes, "sm:max-w-sm"
    assert_includes classes, "w-[300px]"
    assert_includes classes, "sm:max-w-lg"
  end

  private

  def render_sheet
    phlex do
      RubyUI.Sheet do
        RubyUI.SheetTrigger do
          RubyUI.Button { "Open" }
        end
        RubyUI.SheetContent { "Content" }
      end
    end
  end

  # `->` inside a data-action value carries a ">", so the open tag cannot be scanned with [^>]*.
  def dialog_tag(output)
    output[/<dialog\b(?:->|[^>])*>/m].to_s
  end

  def render_content(**attrs)
    phlex { RubyUI.SheetContent(**attrs) { "Content" } }
  end

  def dialog_classes(**attrs)
    dialog_tag(render_content(**attrs))[/\sclass="([^"]*)"/, 1].to_s.split
  end

  def assert_dialog_classes(*expected, **attrs)
    classes = dialog_classes(**attrs)

    expected.each { |class_name| assert_includes classes, class_name, "SheetContent(#{attrs})" }
  end
end
