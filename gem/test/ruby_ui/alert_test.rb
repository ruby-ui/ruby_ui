# frozen_string_literal: true

require "test_helper"

class RubyUI::AlertTest < ComponentTest
  def test_render_with_all_items
    output = phlex do
      RubyUI.Alert do
        RubyUI.AlertTitle { "Pro tip" }
        RubyUI.AlertDescription { "Simply, don't include an icon and your alert will look like this." }
        RubyUI.AlertAction { "Undo" }
      end
    end

    assert_match(/<div[^>]*data-slot="alert"/, output)
    assert_match(/<div data-slot="alert-title" class="[^"]*">Pro tip</, output)
    assert_match(/data-slot="alert-description"/, output)
    assert_match(/<div data-slot="alert-action" class="[^"]*">Undo</, output)
    refute_match(/<h5/, output)
  end

  def test_announces_as_alert_by_default
    output = phlex { RubyUI.Alert { "Saved" } }

    assert_match(/role="alert"/, output)
  end

  def test_role_can_be_removed_for_static_callouts
    output = phlex { RubyUI.Alert(role: nil) { "Pro tip" } }

    refute_match(/role=/, output)
  end

  def test_user_role_replaces_the_default
    output = phlex { RubyUI.Alert(role: "status") { "Saved" } }

    assert_match(/role="status"/, output)
    refute_match(/alert status/, output)
  end

  def test_default_variant_uses_card_colors
    [nil, :default, "default", :info].each do |variant|
      output = phlex { RubyUI.Alert(variant: variant) { "Hi" } }

      assert_match(/bg-card text-card-foreground/, output, "variant #{variant.inspect}")
    end
  end

  def test_colored_variants_tint_text_not_background
    {destructive: "destructive", warning: "warning", success: "success"}.each do |variant, token|
      output = phlex { RubyUI.Alert(variant: variant) { "Hi" } }

      assert_match(/text-#{token} bg-card/, output)
      assert_match(%r{data-\[slot=alert-description\]:text-#{token}/90}, output)
      refute_match(/bg-#{token}/, output)
    end
  end

  def test_icon_gets_its_own_grid_column
    output = phlex { RubyUI.Alert { "Hi" } }

    assert_match(/has-\[>svg\]:grid-cols-\[auto_1fr\]/, output)
  end
end
