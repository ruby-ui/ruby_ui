# frozen_string_literal: true

require "test_helper"

class RubyUI::ToastTest < ComponentTest
  def test_compose_region_with_item_and_slots
    out = phlex {
      RubyUI.ToastRegion {
        RubyUI.ToastItem(variant: :success) {
          RubyUI.ToastIcon(variant: :success)
          RubyUI.ToastTitle { "Saved" }
          RubyUI.ToastDescription { "All good" }
          RubyUI.ToastAction(label: "Undo", on: "click->thing#undo")
          RubyUI.ToastClose()
        }
      }
    }
    assert_match(/Saved/, out)
    assert_match(/All good/, out)
    assert_match(/Undo/, out)
    assert_match(/data-slot="toast-close"/, out)
    assert_match(/data-slot="toast-icon"/, out)
  end

  def test_flash_variant_helper
    assert_equal :info, RubyUI::Toast.flash_variant(:notice)
    assert_equal :warning, RubyUI::Toast.flash_variant("alert")
    assert_equal :default, RubyUI::Toast.flash_variant(:unknown)
  end

  def test_action_is_an_outline_sm_button_that_closes
    out = phlex { RubyUI.ToastAction(label: "Undo", on: "click->thing#undo") }
    assert_match(/Undo/, out)
    assert_match(/data-slot="toast-action"/, out)
    refute_match(/data-slot="button/, out)
    assert_match(/data-action="click-(&gt;|>)thing#undo click-(&gt;|>)ruby-ui--toast#close"/, out)
    assert_match(/border-border bg-background/, out)
    assert_match(/h-8/, out)
  end

  def test_cancel_is_a_ghost_sm_button_that_dismisses
    out = phlex { RubyUI.ToastCancel(label: "Dismiss") }
    assert_match(/Dismiss/, out)
    assert_match(/data-slot="toast-cancel"/, out)
    assert_match(/click-(&gt;|>)ruby-ui--toast#dismiss/, out)
    assert_match(/h-8/, out)
  end

  def test_icon_renders_per_variant
    {
      success: /circle[^>]*r="10"/,
      info: /M12 16v-4/,
      warning: /m21\.73 18/,
      error: /6\.624a2 2 0 0 1 1\.414/,
      loading: /animate-spin/
    }.each do |variant, pattern|
      out = phlex { RubyUI.ToastIcon(variant: variant) }
      assert_match(pattern, out, "expected #{variant} icon to match #{pattern.inspect}")
    end
  end

  def test_error_icon_is_destructive
    out = phlex { RubyUI.ToastIcon(variant: :error) }
    assert_match(/text-destructive/, out)
    assert_match(/data-slot="toast-icon"/, out)
  end

  def test_icon_default_variant_renders_nothing
    out = phlex { RubyUI.ToastIcon(variant: :default) }
    refute_match(/<svg/, out)
  end

  def test_close_is_a_ghost_icon_sm_button
    out = phlex { RubyUI.ToastClose() }
    assert_match(/data-slot="toast-close"/, out)
    assert_match(/aria-label="Close toast"/, out)
    assert_match(/click-(&gt;|>)ruby-ui--toast#dismiss/, out)
    assert_match(/h-8 w-8/, out)
    assert_match(/text-muted-foreground/, out)
    refute_match(/absolute right-2/, out)
  end

  def test_title_and_description_slot_attrs
    title_out = phlex { RubyUI.ToastTitle { "Saved" } }
    desc_out = phlex { RubyUI.ToastDescription { "details" } }
    assert_match(/<h2 data-slot="toast-title" class="text-sm font-medium">Saved<\/h2>/, title_out)
    assert_match(/<p data-slot="toast-description" class="text-sm text-muted-foreground">details<\/p>/, desc_out)
  end
end
