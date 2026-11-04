# frozen_string_literal: true

require "test_helper"

class RubyUI::ToastItemTest < ComponentTest
  def test_renders_base_ui_dialog_role
    out = phlex { RubyUI.ToastItem { "hi" } }
    assert_match(/<div[^>]*role="dialog"/, out)
    assert_match(/aria-modal="false"/, out)
    assert_match(/data-slot="toast"/, out)
    assert_match(/data-type="default"/, out)
    assert_match(/data-controller="ruby-ui--toast"/, out)
    assert_match(/data-ruby-ui--toaster-target="toast"/, out)
    assert_match(/data-state="pending"/, out)
  end

  def test_no_live_region_role_per_toast
    out = phlex { RubyUI.ToastItem(variant: :error) { "x" } }
    refute_match(/role="(status|alert)"/, out)
    refute_match(/aria-atomic/, out)
    assert_match(/role="dialog"/, out)
  end

  def test_wraps_block_in_toast_content
    out = phlex { RubyUI.ToastItem { "hi" } }
    assert_match(/<div data-slot="toast-content" class="[^"]*gap-3[^"]*p-4[^"]*">hi<\/div>/, out)
  end

  def test_vega_card_classes
    out = phlex { RubyUI.ToastItem { "x" } }
    assert_match(/rounded-2xl/, out)
    assert_match(/shadow-lg/, out)
    refute_match(/text-\[13px\]/, out)
  end

  def test_high_priority_is_alertdialog
    out = phlex { RubyUI.ToastItem(priority: :high) { "x" } }
    assert_match(/role="alertdialog"/, out)
    assert_match(/data-priority="high"/, out)
  end

  def test_unknown_priority_raises
    assert_raises(ArgumentError) { RubyUI::ToastItem.new(priority: :urgent) }
  end

  def test_duration_propagated_as_data_value
    out = phlex { RubyUI.ToastItem(duration: 7000) { "x" } }
    assert_match(/data-ruby-ui--toast-duration-value="7000"/, out)
  end

  def test_duration_omitted_inherits_region
    out = phlex { RubyUI.ToastItem { "x" } }
    refute_match(/data-ruby-ui--toast-duration-value/, out)
  end

  def test_dismissible_default_true
    out = phlex { RubyUI.ToastItem { "x" } }
    assert_match(/data-ruby-ui--toast-dismissible-value="true"/, out)
  end

  def test_id_attribute
    out = phlex { RubyUI.ToastItem(id: "abc") { "x" } }
    assert_match(/id="abc"/, out)
  end

  def test_on_dismiss_and_on_remove_bind_toast_events
    out = phlex { RubyUI.ToastItem(on_dismiss: "undo#commit", on_remove: "undo#cleanup") { "x" } }
    assert_match(/data-action="ruby-ui:toast:close-&gt;undo#commit ruby-ui:toast:remove-&gt;undo#cleanup"|data-action="ruby-ui:toast:close->undo#commit ruby-ui:toast:remove->undo#cleanup"/, out)
  end

  def test_removed_kwargs_raise
    %i[invert on_auto_close].each do |kwarg|
      error = assert_raises(ArgumentError) { RubyUI::ToastItem.new(kwarg => true) }
      assert_match(/#{kwarg}:/, error.message)
    end
  end
end
