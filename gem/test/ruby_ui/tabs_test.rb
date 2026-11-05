# frozen_string_literal: true

require "test_helper"

class RubyUI::TabsTest < ComponentTest
  def render_tabs(**tabs_attrs)
    phlex do
      RubyUI.Tabs(**tabs_attrs) do
        RubyUI.TabsList do
          RubyUI.TabsTrigger(value: "account") { "Account" }
          RubyUI.TabsTrigger(value: "password") { "Password" }
        end
        RubyUI.TabsContent(value: "account") { "Account panel" }
        RubyUI.TabsContent(value: "password") { "Password panel" }
      end
    end
  end

  def test_render_with_all_items
    output = render_tabs(default_value: "account", class: "w-96")

    assert_match(/Account panel/, output)
    assert_match(/Password panel/, output)
  end

  def test_root_carries_slot_orientation_and_default_value
    output = render_tabs(default_value: "password")

    assert_match(/data-slot="tabs"/, output)
    assert_match(/data-orientation="horizontal"/, output)
    assert_match(/data-ruby-ui--tabs-active-value="password"/, output)
    assert_match(/data-\[orientation=horizontal\]:flex-col/, output)
    refute_match(/default-value=/, output)
  end

  def test_default_is_an_alias_for_default_value
    output = render_tabs(default: "password")

    assert_match(/data-ruby-ui--tabs-active-value="password"/, output)
    refute_match(/\sdefault=/, output)
  end

  def test_default_value_wins_over_the_alias
    output = render_tabs(default_value: "account", default: "password")

    assert_match(/data-ruby-ui--tabs-active-value="account"/, output)
  end

  def test_without_default_value_no_active_value_is_rendered
    output = render_tabs

    refute_match(/data-ruby-ui--tabs-active-value/, output)
  end

  def test_vertical_orientation
    output = render_tabs(orientation: :vertical)

    assert_match(/data-orientation="vertical"/, output)
    assert_match(/data-ruby-ui--tabs-orientation-value="vertical"/, output)
  end

  def test_unknown_orientation_falls_back_to_horizontal
    output = render_tabs(orientation: :diagonal)

    assert_match(/data-orientation="horizontal"/, output)
  end

  def test_list_is_a_tablist_with_the_default_variant
    output = phlex { RubyUI.TabsList { "" } }

    assert_match(/role="tablist"/, output)
    assert_match(/data-slot="tabs-list"/, output)
    assert_match(/data-variant="default"/, output)
    assert_match(/keydown->ruby-ui--tabs#keydown focusout->ruby-ui--tabs#listFocusout/, output)
    assert_match(/bg-muted/, output)
    refute_match(/data-activate-on-focus|data-loop-focus/, output)
  end

  def test_line_variant
    output = phlex { RubyUI.TabsList(variant: :line) { "" } }

    assert_match(/data-variant="line"/, output)
    assert_match(/bg-transparent/, output)
    refute_match(/bg-muted/, output)
  end

  def test_list_keyboard_options
    output = phlex { RubyUI.TabsList(activate_on_focus: true, loop_focus: false) { "" } }

    assert_match(/data-activate-on-focus="true"/, output)
    assert_match(/data-loop-focus="false"/, output)
  end

  def test_list_height_can_be_overridden
    output = phlex { RubyUI.TabsList(class: "h-10") { "" } }

    assert_match(/\bh-10\b/, output)
    refute_match(/\bh-9\b/, output)
  end

  def test_trigger_is_a_tab_button
    output = phlex { RubyUI.TabsTrigger(value: "account") { "Account" } }

    assert_match(/<button[^>]*role="tab"/, output)
    assert_match(/type="button"/, output)
    assert_match(/aria-selected="false"/, output)
    assert_match(/data-slot="tabs-trigger"/, output)
    assert_match(/data-value="account"/, output)
    refute_match(/aria-disabled="|data-disabled[\s>=]/, output)
  end

  def test_disabled_trigger_uses_aria_disabled
    output = phlex { RubyUI.TabsTrigger(value: "billing", disabled: true) { "Billing" } }

    assert_match(/aria-disabled="true"/, output)
    assert_match(/data-disabled/, output)
    refute_match(/\sdisabled(=|\s|>)/, output)
  end

  def test_trigger_as_link
    output = phlex { RubyUI.TabsTrigger(value: "account", as: :a, href: "?tab=account") { "Account" } }

    assert_match(/<a[^>]*role="tab"/, output)
    assert_match(/href="\?tab=account"/, output)
    refute_match(/type="button"/, output)
  end

  def test_content_is_a_hidden_focusable_tabpanel
    output = phlex { RubyUI.TabsContent(value: "account") { "Panel" } }

    assert_match(/role="tabpanel"/, output)
    assert_match(/tabindex="0"/, output)
    assert_match(/\shidden(\s|>)/, output)
    assert_match(/data-slot="tabs-content"/, output)
    assert_match(/text-sm/, output)
    refute_match(/\bmt-2\b/, output)
  end
end
