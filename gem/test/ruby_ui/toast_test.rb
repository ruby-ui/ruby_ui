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
    assert_match(/data-slot="close"/, out)
    assert_match(/data-slot="icon"/, out)
  end

  def test_flash_variant_helper
    assert_equal :info, RubyUI::Toast.flash_variant(:notice)
    assert_equal :warning, RubyUI::Toast.flash_variant("alert")
    assert_equal :default, RubyUI::Toast.flash_variant(:unknown)
  end

  def test_action_renders_label_and_action_attr
    out = phlex { RubyUI.ToastAction(label: "Undo", on: "click->thing#undo") }
    assert_match(/Undo/, out)
    assert_match(/data-slot="action"/, out)
    assert_match(/data-action="click->thing#undo"/, out)
  end

  def test_cancel_renders_label_and_dismiss_action
    out = phlex { RubyUI.ToastCancel(label: "Dismiss") }
    assert_match(/Dismiss/, out)
    assert_match(/data-slot="cancel"/, out)
    assert_match(/click-&gt;ruby-ui--toast#dismiss|click->ruby-ui--toast#dismiss/, out)
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

  def test_icon_default_variant_renders_nothing
    out = phlex { RubyUI.ToastIcon(variant: :default) }
    refute_match(/<svg/, out)
  end

  def test_close_renders_dismiss_action
    out = phlex { RubyUI.ToastClose() }
    assert_match(/data-slot="close"/, out)
    assert_match(/click-&gt;ruby-ui--toast#dismiss|click->ruby-ui--toast#dismiss/, out)
    assert_match(/sr-only/, out)
  end

  def test_title_and_description_slot_attrs
    title_out = phlex { RubyUI.ToastTitle { "Saved" } }
    desc_out = phlex { RubyUI.ToastDescription { "details" } }
    assert_match(/data-slot="title"/, title_out)
    assert_match(/Saved/, title_out)
    assert_match(/data-slot="description"/, desc_out)
    assert_match(/details/, desc_out)
  end
end
