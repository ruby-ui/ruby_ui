# frozen_string_literal: true

require "test_helper"

class RubyUI::ToastRegionTest < ComponentTest
  def test_renders_toast_container_with_target_id
    out = phlex { RubyUI.ToastRegion() }
    assert_match(/<div id="ruby-ui-toaster"/, out)
    assert_match(/data-controller="ruby-ui--toaster"/, out)
  end

  def test_outer_wrapper_has_id_and_turbo_permanent
    out = phlex { RubyUI.ToastRegion() }
    assert_match(/<div[^>]*id="ruby-ui-toaster-region"/, out)
    assert_match(/data-turbo-permanent/, out)
  end

  def test_viewport_matches_base_ui
    out = phlex { RubyUI.ToastRegion() }
    assert_match(/data-slot="toast-viewport"/, out)
    assert_match(/max-w-sm/, out)
    assert_match(/inset-x-4/, out)
    assert_match(/data-\[position\^=bottom\]:bottom-4/, out)
    refute_match(/sm:p-6/, out)
  end

  def test_region_is_a_manual_popover
    out = phlex { RubyUI.ToastRegion() }
    assert_match(/popover="manual"/, out)
  end

  def test_single_polite_live_region
    out = phlex { RubyUI.ToastRegion() }
    assert_match(/role="region"/, out)
    assert_match(/aria-label="Notifications"/, out)
    assert_match(/aria-live="polite"/, out)
    assert_match(/aria-relevant="additions text"/, out)
    assert_match(/aria-atomic="false"/, out)
  end

  def test_position_attr
    out = phlex { RubyUI.ToastRegion(position: :top_left) }
    assert_match(/data-position="top-left"/, out)
  end

  def test_unknown_position_raises
    assert_raises(ArgumentError) { RubyUI::ToastRegion.new(position: :middle) }
  end

  def test_base_ui_defaults
    out = phlex { RubyUI.ToastRegion() }
    assert_match(/data-ruby-ui--toaster-duration-value="5000"/, out)
    assert_match(/data-ruby-ui--toaster-gap-value="12"/, out)
    assert_match(/data-ruby-ui--toaster-max-value="3"/, out)
    assert_match(/data-ruby-ui--toaster-hotkey-value="F6"/, out)
    assert_match(/data-ruby-ui--toaster-close-button-value="true"/, out)
  end

  def test_value_props
    out = phlex { RubyUI.ToastRegion(max: 5, duration: 8000, swipe_directions: %i[left right]) }
    assert_match(/data-ruby-ui--toaster-max-value="5"/, out)
    assert_match(/data-ruby-ui--toaster-duration-value="8000"/, out)
    assert_match(/data-ruby-ui--toaster-swipe-directions-value="left right"/, out)
  end

  def test_empty_swipe_directions_disable_swipe
    out = phlex { RubyUI.ToastRegion(swipe_directions: []) }
    assert_match(/data-ruby-ui--toaster-swipe-directions-value="none"/, out)
  end

  def test_skeletons_render_close_button_by_default
    out = phlex { RubyUI.ToastRegion() }
    %w[default success error warning info loading].each do |v|
      assert_match(/data-variant="#{v}"/, out)
    end
    assert_match(/<template data-ruby-ui--toaster-target="skeleton" data-variant="default">.*data-slot="toast-close"/m, out)
  end

  def test_close_button_false_drops_the_x_from_skeletons
    out = phlex { RubyUI.ToastRegion(close_button: false) }
    skeleton = out[/<template data-ruby-ui--toaster-target="skeleton" data-variant="default">.*?<\/template>/m]
    refute_match(/data-slot="toast-close"/, skeleton)
  end

  def test_removed_kwargs_raise
    %i[offset theme rich_colors dir].each do |kwarg|
      error = assert_raises(ArgumentError) { RubyUI::ToastRegion.new(kwarg => 1) }
      assert_match(/#{kwarg}:/, error.message)
    end
  end

  def test_renders_flash_messages
    out = phlex { RubyUI.ToastRegion(flash: {"notice" => "Saved", "alert" => "Oops"}) }
    assert_match(/Saved/, out)
    assert_match(/Oops/, out)
    assert_match(/id="flash-notice"/, out)
  end
end
