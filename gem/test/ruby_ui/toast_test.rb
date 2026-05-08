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
end
