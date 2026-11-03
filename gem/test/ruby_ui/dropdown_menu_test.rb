# frozen_string_literal: true

require "test_helper"

class RubyUI::DropdownMenuTest < ComponentTest
  def test_render_with_all_parts
    output = phlex do
      RubyUI.DropdownMenu do
        RubyUI.DropdownMenuTrigger do
          RubyUI.Button(variant: :outline) { "Open" }
        end
        RubyUI.DropdownMenuContent do
          RubyUI.DropdownMenuGroup do
            RubyUI.DropdownMenuLabel { "My Account" }
            RubyUI.DropdownMenuItem { RubyUI.DropdownMenuShortcut { "⇧⌘P" } }
            RubyUI.DropdownMenuItem(disabled: true) { "Billing" }
          end
          RubyUI.DropdownMenuSeparator()
          RubyUI.DropdownMenuCheckboxItem(checked: true) { "Status Bar" }
          RubyUI.DropdownMenuRadioGroup do
            RubyUI.DropdownMenuRadioItem(value: "top", checked: true) { "Top" }
            RubyUI.DropdownMenuRadioItem(value: "bottom") { "Bottom" }
          end
          RubyUI.DropdownMenuSub do
            RubyUI.DropdownMenuSubTrigger { "Invite users" }
            RubyUI.DropdownMenuSubContent do
              RubyUI.DropdownMenuItem { "Email" }
            end
          end
          RubyUI.DropdownMenuItem(variant: :destructive) { "Log out" }
        end
      end
    end

    assert_match(/data-slot="dropdown-menu"[^<]*data-controller="ruby-ui--dropdown-menu"/, output)
    assert_match(/data-slot="dropdown-menu-shortcut"[^<]*>⇧⌘P/, output)
    assert_match(/role="menuitem"[^<]*aria-disabled="true"[^<]*data-disabled/, output)
    assert_match(/role="menuitemcheckbox"[^<]*aria-checked="true"/, output)
    assert_match(/role="menuitemradio"[^<]*aria-checked="false"/, output)
    assert_match(/data-variant="destructive"/, output)
    assert_match(/role="separator"[^<]*data-slot="dropdown-menu-separator"/, output)
  end

  def test_root_carries_open_and_modal_values
    output = phlex { RubyUI.DropdownMenu(open: true, modal: false) { "x" } }

    assert_match(/data-ruby-ui--dropdown-menu-open-value="true"/, output)
    assert_match(/data-ruby-ui--dropdown-menu-modal-value="false"/, output)
  end

  def test_root_is_modal_and_closed_by_default
    output = phlex { RubyUI.DropdownMenu { "x" } }

    assert_match(/data-ruby-ui--dropdown-menu-open-value="false"/, output)
    assert_match(/data-ruby-ui--dropdown-menu-modal-value="true"/, output)
  end

  # The legacy placement option still reaches the controller.
  def test_root_keeps_legacy_options
    output = phlex { RubyUI.DropdownMenu(options: {placement: "top-end"}) { "x" } }

    assert_match(/data-ruby-ui--dropdown-menu-options-value="{&quot;placement&quot;:&quot;top-end&quot;}"/, output)
  end

  # The wrapper takes no box: the button inside is the trigger.
  def test_trigger_wraps_the_button_without_a_box
    output = phlex { RubyUI.DropdownMenuTrigger { RubyUI.Button { "Open" } } }

    assert_match(/\A<div[^<]*data-ruby-ui--dropdown-menu-target="trigger"[^<]*class="contents"/, output)
    assert_match(/data-action="click->ruby-ui--dropdown-menu#toggle"/, output)
  end

  # A native popover (top layer) placed with Floating UI, closed until opened.
  def test_content_is_a_closed_popover_menu
    output = phlex { RubyUI.DropdownMenuContent { RubyUI.DropdownMenuItem { "Profile" } } }

    assert_match(/<div role="menu" tabindex="-1" popover="manual"/, output)
    assert_match(/data-slot="dropdown-menu-content"/, output)
    assert_match(/data-closed=""/, output)
    assert_match(/data-side-offset="4"/, output)
    assert_match(/data-align-offset="0"/, output)
    refute_match(/data-preferred-side=/, output)
  end

  def test_content_uses_vega_surface_and_sizing
    output = phlex { RubyUI.DropdownMenuContent { "menu body" } }

    %w[bg-popover text-popover-foreground ring-1 ring-foreground/10 min-w-32 w-(--anchor-width)
      max-h-(--available-height) overflow-y-auto duration-100 data-closed:fill-mode-forwards].each do |token|
      assert_includes output, token
    end
    refute_match(/\bborder\b(?!-0)/, output)
  end

  def test_content_takes_side_and_align
    output = phlex { RubyUI.DropdownMenuContent(side: :top, align: :end, side_offset: 8, align_offset: 2) { "x" } }

    assert_match(/data-preferred-side="top"/, output)
    assert_match(/data-align="end"/, output)
    assert_match(/data-side-offset="8"/, output)
    assert_match(/data-align-offset="2"/, output)
  end

  def test_unknown_side_is_left_to_the_default
    output = phlex { RubyUI.DropdownMenuContent(side: :middle) { "x" } }

    refute_match(/data-preferred-side=/, output)
  end

  # Inside a group the label names it and is hidden from the accessibility tree.
  def test_label_names_its_group
    output = phlex do
      RubyUI.DropdownMenuGroup(id: "account") do
        RubyUI.DropdownMenuLabel { "My Account" }
        RubyUI.DropdownMenuItem { "Profile" }
      end
    end

    assert_match(/<div aria-labelledby="account-label" role="group"/, output)
    assert_match(/<div aria-hidden="true" data-slot="dropdown-menu-label"[^<]*id="account-label"/, output)
    assert_includes output, "text-xs font-medium"
    refute_match(/<h3/, output)
  end

  def test_label_outside_a_group_is_plain_text
    output = phlex { RubyUI.DropdownMenuLabel(inset: true) { "My Account" } }

    assert_match(/\A<div data-slot="dropdown-menu-label" data-inset/, output)
    refute_match(/aria-hidden/, output)
  end

  def test_group_without_label_has_no_labelledby
    output = phlex { RubyUI.DropdownMenuGroup { RubyUI.DropdownMenuItem { "Profile" } } }

    refute_match(/aria-labelledby/, output)
  end

  def test_separator_uses_border_color
    output = phlex { RubyUI.DropdownMenuSeparator() }

    assert_includes output, "bg-border"
    assert_match(/data-orientation="horizontal"/, output)
  end

  def test_checkbox_item_shows_indicator_when_checked
    output = phlex { RubyUI.DropdownMenuCheckboxItem { "Status Bar" } }

    assert_match(/aria-checked="false"/, output)
    assert_match(/data-slot="dropdown-menu-checkbox-item-indicator"/, output)
    assert_includes output, "group-aria-checked/dropdown-menu-checkbox-item:flex"
  end

  def test_radio_item_carries_its_value
    output = phlex { RubyUI.DropdownMenuRadioItem(value: "top") { "Top" } }

    assert_match(/data-value="top"/, output)
    assert_includes output, "group-aria-checked/dropdown-menu-radio-item:flex"
  end

  # The sub's id ties the trigger to its submenu.
  def test_sub_links_trigger_and_content
    output = phlex do
      RubyUI.DropdownMenuSub(id: "invite") do
        RubyUI.DropdownMenuSubTrigger { "Invite users" }
        RubyUI.DropdownMenuSubContent { RubyUI.DropdownMenuItem { "Email" } }
      end
    end

    trigger = output[/<div [^<]*data-slot="dropdown-menu-sub-trigger"[^<]*>/]
    content = output[/<div [^<]*data-slot="dropdown-menu-sub-content"[^<]*>/]
    %w[id="invite-trigger" role="menuitem" aria-haspopup="menu" aria-expanded="false" aria-controls="invite-content"].each { |a| assert_includes trigger, a }
    %w[id="invite-content" role="menu" popover="manual" aria-labelledby="invite-trigger"].each { |a| assert_includes content, a }
    assert_match(/data-preferred-side="right"[^<]*data-align="start"[^<]*data-side-offset="0"[^<]*data-align-offset="-3"/, output)
    assert_includes output, "min-w-[96px]"
  end

  # A caller's id: can't break the trigger/submenu link.
  def test_sub_ids_win_over_caller_ids
    output = phlex do
      RubyUI.DropdownMenuSub(id: "invite") do
        RubyUI.DropdownMenuSubTrigger(id: "mine", aria: {label: "Invite"}) { "Invite users" }
        RubyUI.DropdownMenuSubContent(id: "theirs") { RubyUI.DropdownMenuItem { "Email" } }
      end
    end

    trigger = output[/<div [^<]*data-slot="dropdown-menu-sub-trigger"[^<]*>/]
    content = output[/<div [^<]*data-slot="dropdown-menu-sub-content"[^<]*>/]
    %w[id="invite-trigger" aria-label="Invite" aria-controls="invite-content"].each { |a| assert_includes trigger, a }
    %w[id="invite-content" aria-labelledby="invite-trigger"].each { |a| assert_includes content, a }
    refute_match(/id="(mine|theirs)"/, output)
  end
end
