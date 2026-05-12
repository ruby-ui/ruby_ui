# frozen_string_literal: true

require "test_helper"

class RubyUI::ToastRegionTest < ComponentTest
  def test_renders_ol_with_target_id
    out = phlex { RubyUI.ToastRegion() }
    assert_match(/<ol[^>]*id="ruby-ui-toaster"/, out)
    assert_match(/data-controller="ruby-ui--toaster"/, out)
  end

  def test_outer_wrapper_has_id_and_turbo_permanent
    out = phlex { RubyUI.ToastRegion() }
    assert_match(/<div[^>]*id="ruby-ui-toaster-region"/, out)
    assert_match(/data-turbo-permanent/, out)
  end

  def test_position_attr
    out = phlex { RubyUI.ToastRegion(position: :top_left) }
    assert_match(/data-position="top-left"/, out)
  end

  def test_default_value_props
    out = phlex { RubyUI.ToastRegion(max: 5, duration: 8000) }
    assert_match(/data-ruby-ui--toaster-max-value="5"/, out)
    assert_match(/data-ruby-ui--toaster-duration-value="8000"/, out)
  end

  def test_renders_skeleton_per_variant
    out = phlex { RubyUI.ToastRegion() }
    %w[default success error warning info loading].each do |v|
      assert_match(/data-variant="#{v}"/, out)
    end
  end

  def test_role_region_aria_live
    out = phlex { RubyUI.ToastRegion() }
    assert_match(/role="region"/, out)
    assert_match(/aria-live="polite"/, out)
  end

  def test_renders_flash_messages
    out = phlex { RubyUI.ToastRegion(flash: {"notice" => "Saved", "alert" => "Oops"}) }
    assert_match(/Saved/, out)
    assert_match(/Oops/, out)
    assert_match(/id="flash-notice"/, out)
  end
end
