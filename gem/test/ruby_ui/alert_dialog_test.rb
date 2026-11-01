# frozen_string_literal: true

require "test_helper"

class RubyUI::AlertDialogTest < ComponentTest
  def test_render_with_all_items
    output = phlex do
      RubyUI.AlertDialog do
        RubyUI.AlertDialogTrigger do
          RubyUI.Button { "Show dialog" }
        end
        RubyUI.AlertDialogContent do
          RubyUI.AlertDialogHeader do
            RubyUI.AlertDialogTitle { "Are you absolutely sure?" }
            RubyUI.AlertDialogDescription { "This action cannot be undone. This will permanently delete your account and remove your data from our servers." }
          end
          RubyUI.AlertDialogFooter do
            RubyUI.AlertDialogCancel { "Cancel" }
            RubyUI.AlertDialogAction { "Continue" }
          end
        end
      end
    end

    assert_match(/Show dialog/, output)
  end

  def test_root_is_a_box_less_div_with_the_controller
    output = phlex { RubyUI.AlertDialog { "x" } }

    assert_match(/<div[^>]*data-controller="ruby-ui--alert-dialog"/, output)
    assert_includes classes_of(output, "div"), "contents"
    refute_includes classes_of(output, "div"), "inline-block"
  end

  def test_root_open_value
    assert_match(/data-ruby-ui--alert-dialog-open-value="true"/, phlex { RubyUI.AlertDialog(open: true) { "x" } })
    assert_match(/data-ruby-ui--alert-dialog-open-value="false"/, phlex { RubyUI.AlertDialog { "x" } })
  end

  def test_trigger_is_a_target_that_opens
    output = phlex { RubyUI.AlertDialogTrigger { "x" } }

    assert_match(/data-ruby-ui--alert-dialog-target="trigger"/, output)
    assert_match(/data-action="click->ruby-ui--alert-dialog#open"/, output)
  end

  def test_content_renders_native_dialog_with_alertdialog_role
    output = content_output

    assert_match(/<dialog[^>]*role="alertdialog"/, output)
    assert_match(/data-ruby-ui--alert-dialog-target="dialog"/, output)
    refute_match(/<template[\s>]/, output)
  end

  # An alert dialog doesn't close on a backdrop click (APG alertdialog), unlike Dialog.
  def test_content_has_no_backdrop_click_action
    refute_match(/backdropClick/, content_output)
  end

  def test_content_does_not_force_display_when_closed
    classes = classes_of(content_output, "dialog")

    refute_includes classes, "grid"
    refute_includes classes, "flex"
    assert_includes classes, "open:grid"
  end

  def test_content_vega_classes
    classes = classes_of(content_output, "dialog")

    %w[
      group/alert-dialog-content open:grid top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-full outline-none
      bg-popover text-popover-foreground ring-1 ring-foreground/10 gap-6 rounded-xl p-6
      data-[size=default]:max-w-xs data-[size=sm]:max-w-xs data-[size=default]:sm:max-w-lg
      backdrop:bg-black/10 supports-backdrop-filter:backdrop:backdrop-blur-xs
    ].each { |klass| assert_includes classes, klass }
    %w[border shadow-lg gap-4 sm:rounded-lg bg-background max-w-lg].each { |klass| refute_includes classes, klass }
  end

  def test_content_animation_classes
    classes = classes_of(content_output, "dialog")

    %w[
      duration-100 backdrop:duration-100
      data-[state=open]:animate-in data-[state=open]:fade-in-0 data-[state=open]:zoom-in-95
      data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=closed]:zoom-out-95
      data-[state=open]:backdrop:animate-in data-[state=open]:backdrop:fade-in-0
      data-[state=closed]:backdrop:animate-out data-[state=closed]:backdrop:fade-out-0
      data-[state=closed]:fill-mode-forwards data-[state=closed]:backdrop:fill-mode-forwards
    ].each { |klass| assert_includes classes, klass }
  end

  def test_content_size
    assert_match(/<dialog[^>]*data-size="default"/, content_output)
    assert_match(/<dialog[^>]*data-size="sm"/, phlex { RubyUI.AlertDialogContent(size: :sm) { "x" } })
  end

  def test_content_rejects_unknown_size
    assert_raises(ArgumentError) { phlex { RubyUI.AlertDialogContent(size: :lg) { "x" } } }
  end

  def test_header_vega_classes
    classes = classes_of(phlex { RubyUI.AlertDialogHeader { "x" } }, "div")

    %w[grid grid-rows-[auto_1fr] place-items-center gap-1.5 text-center sm:group-data-[size=default]/alert-dialog-content:place-items-start sm:group-data-[size=default]/alert-dialog-content:text-left].each do |klass|
      assert_includes classes, klass
    end
    %w[flex space-y-2].each { |klass| refute_includes classes, klass }
  end

  def test_title_vega_classes_and_target
    output = phlex { RubyUI.AlertDialogTitle { "x" } }

    assert_match(/<h2[^>]*data-ruby-ui--alert-dialog-target="title"/, output)
    assert_includes classes_of(output, "h2"), "font-medium"
    assert_includes classes_of(output, "h2"), "font-heading"
    refute_includes classes_of(output, "h2"), "font-semibold"
  end

  def test_description_vega_classes_and_target
    output = phlex { RubyUI.AlertDialogDescription { "x" } }

    assert_match(/<p[^>]*data-ruby-ui--alert-dialog-target="description"/, output)
    %w[text-sm text-muted-foreground text-balance md:text-pretty *:[a]:underline *:[a]:underline-offset-3 *:[a]:hover:text-foreground].each do |klass|
      assert_includes classes_of(output, "p"), klass
    end
  end

  def test_footer_vega_classes
    classes = classes_of(phlex { RubyUI.AlertDialogFooter { "x" } }, "div")

    %w[flex flex-col-reverse gap-2 sm:flex-row sm:justify-end group-data-[size=sm]/alert-dialog-content:grid group-data-[size=sm]/alert-dialog-content:grid-cols-2].each do |klass|
      assert_includes classes, klass
    end
    refute_includes classes, "sm:space-x-2"
  end

  def test_cancel_dismisses_without_margin_hack
    output = phlex { RubyUI.AlertDialogCancel { "Cancel" } }

    assert_match(/data-action="click->ruby-ui--alert-dialog#dismiss"/, output)
    refute_includes classes_of(output, "button"), "mt-2"
  end

  def test_media
    output = phlex { RubyUI.AlertDialogMedia { "icon" } }

    assert_match(/<div[^>]*data-slot="alert-dialog-media"/, output)
    %w[bg-muted mb-2 inline-flex size-16 items-center justify-center rounded-md].each do |klass|
      assert_includes classes_of(output, "div"), klass
    end
  end

  private

  def content_output
    phlex { RubyUI.AlertDialogContent { "Content" } }
  end

  def classes_of(output, tag)
    output[/<#{tag}\b[^>]*\sclass="([^"]*)"/m, 1].to_s.split
  end
end
