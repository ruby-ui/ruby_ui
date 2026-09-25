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

  # Regression test: content must be a native <dialog>, not a <template> cloned onto <body>
  def test_content_renders_native_dialog_with_alertdialog_role
    output = render_alert_dialog

    assert_match(/<dialog[^>]*\srole="alertdialog"/, output, "AlertDialogContent must render a native <dialog role=\"alertdialog\">")
    refute_match(/<template[\s>]/, output, "AlertDialogContent must not use a <template> element")
  end

  def test_content_does_not_nest_a_second_controller
    output = render_alert_dialog

    assert_equal 1, output.scan('data-controller="ruby-ui--alert-dialog"').size, "Only the wrapper carries the controller"
    assert_match(/<div[^>]*data-controller="ruby-ui--alert-dialog"/, output, "AlertDialog wrapper must be a <div>")
  end

  def test_content_has_stimulus_target
    assert_match(/<dialog[^>]*data-ruby-ui--alert-dialog-target="dialog"/, render_alert_dialog)
  end

  # Radix parity: Escape closes, clicking the backdrop does not
  def test_content_has_no_backdrop_click_action
    refute_match(/backdropClick/, render_alert_dialog)
  end

  # Regression test: a closed native <dialog> must stay hidden. Bare `flex`
  # overrides the UA `dialog:not([open]) { display: none }`.
  def test_content_does_not_force_display_when_closed
    classes = dialog_classes(render_alert_dialog)

    refute_includes classes, "flex", "Bare `flex` forces a closed <dialog> to display; use `open:flex`"
    assert_includes classes, "open:flex", "AlertDialog must apply flex only when open (open:flex)"
  end

  # The controller owns data-state; the closed markup must not start in one
  def test_content_renders_without_data_state
    refute_match(/<dialog[^>]*\sdata-state=/, render_alert_dialog)
  end

  def test_content_has_enter_and_exit_animations
    assert_dialog_classes(
      "duration-200",
      "data-[state=open]:animate-in",
      "data-[state=open]:fade-in-0",
      "data-[state=open]:zoom-in-95",
      "data-[state=closed]:animate-out",
      "data-[state=closed]:fade-out-0",
      "data-[state=closed]:zoom-out-95",
      "data-[state=closed]:fill-mode-forwards"
    )
  end

  # The backdrop's animationend is dispatched on the <dialog> under the same keyframe name,
  # so its exit must be as long as the panel's or the panel is cut short.
  def test_content_animates_and_styles_backdrop
    assert_dialog_classes(
      "backdrop:bg-background/80",
      "backdrop:backdrop-blur-sm",
      "backdrop:duration-200",
      "data-[state=open]:backdrop:animate-in",
      "data-[state=open]:backdrop:fade-in-0",
      "data-[state=closed]:backdrop:animate-out",
      "data-[state=closed]:backdrop:fade-out-0",
      "data-[state=closed]:backdrop:fill-mode-forwards"
    )
  end

  def test_cancel_autofocuses_and_dismisses
    output = phlex { RubyUI.AlertDialogCancel { "Cancel" } }

    assert_match(/<button[^>]*\sautofocus[\s>]/, output, "Cancel must receive focus when the dialog opens")
    assert_match(/data-action="click->ruby-ui--alert-dialog#dismiss"/, output)
  end

  def test_action_dismisses
    output = phlex { RubyUI.AlertDialogAction { "Continue" } }

    assert_match(/data-action="click->ruby-ui--alert-dialog#dismiss"/, output)
  end

  def test_action_keeps_user_supplied_actions
    output = phlex { RubyUI.AlertDialogAction(data: {action: "click->account#destroy"}) { "Continue" } }

    assert_match(/data-action="click->ruby-ui--alert-dialog#dismiss click->account#destroy"/, output)
  end

  def test_trigger_has_open_action
    assert_match(/data-action="click->ruby-ui--alert-dialog#open"/, render_alert_dialog)
  end

  def test_open_value_is_set_on_wrapper
    output = phlex do
      RubyUI.AlertDialog(open: true) do
        RubyUI.AlertDialogContent { "Content" }
      end
    end

    assert_match(/data-ruby-ui--alert-dialog-open-value="true"/, output)
  end

  private

  def render_alert_dialog
    phlex do
      RubyUI.AlertDialog do
        RubyUI.AlertDialogTrigger do
          RubyUI.Button { "Open" }
        end
        RubyUI.AlertDialogContent { "Content" }
      end
    end
  end

  def dialog_classes(output)
    output[/<dialog\b.*?\sclass="([^"]*)"/m, 1].to_s.split
  end

  def assert_dialog_classes(*expected)
    classes = dialog_classes(render_alert_dialog)
    expected.each { |class_name| assert_includes classes, class_name }
  end
end
