# frozen_string_literal: true

require "test_helper"

class RubyUI::ContextMenuTest < ComponentTest
  def test_render_with_all_parts
    output = phlex do
      RubyUI.ContextMenu do
        RubyUI.ContextMenuTrigger(class: "flex h-[150px] w-[300px] items-center justify-center rounded-md border border-dashed text-sm") { "Right click here" }
        RubyUI.ContextMenuContent(class: "w-64") do
          RubyUI.ContextMenuGroup do
            RubyUI.ContextMenuItem(shortcut: "⌘[") { "Back" }
            RubyUI.ContextMenuItem(shortcut: "⌘]", disabled: true) { "Forward" }
          end
          RubyUI.ContextMenuSeparator
          RubyUI.ContextMenuCheckboxItem(checked: true) { "Show Bookmarks Bar" }
          RubyUI.ContextMenuSeparator
          RubyUI.ContextMenuRadioGroup do
            RubyUI.ContextMenuLabel(inset: true) { "People" }
            RubyUI.ContextMenuRadioItem(value: "pedro", checked: true) { "Pedro Duarte" }
            RubyUI.ContextMenuRadioItem(value: "colm") { "Colm Tuite" }
          end
          RubyUI.ContextMenuItem(variant: :destructive) { "Delete" }
        end
      end
    end

    assert_match(/Right click here/, output)
    assert_match(/data-slot="context-menu-shortcut"[^>]*>⌘\[/, output)
    assert_match(/role="menuitemcheckbox"[^>]*aria-checked="true"/, output)
    assert_match(/role="menuitemradio"[^>]*aria-checked="false"/, output)
    assert_match(/data-variant="destructive"/, output)
  end

  # A native popover (top layer) placed with Floating UI, closed until opened.
  def test_content_is_a_closed_popover_menu
    output = phlex { RubyUI.ContextMenuContent { RubyUI.ContextMenuItem { "Back" } } }

    assert_match(/<div role="menu" tabindex="-1" popover="manual"/, output)
    assert_match(/data-closed=""/, output)
    assert_match(/data-side="right"/, output)
    assert_match(/data-align="start"/, output)
    assert_match(/data-side-offset="0"/, output)
    assert_match(/data-align-offset="4"/, output)
    assert_match(/ring-1 ring-foreground\/10/, output)
    assert_match(/bg-popover/, output)
    refute_match(/<template/, output)
  end

  def test_content_takes_shadcn_placement_props
    output = phlex { RubyUI.ContextMenuContent(side: :left, side_offset: 8, align: :end, align_offset: 2) }

    assert_match(/data-preferred-side="left"/, output)
    assert_match(/data-align="end"/, output)
    assert_match(/data-side-offset="8"/, output)
    assert_match(/data-align-offset="2"/, output)
  end

  def test_content_ignores_unknown_placement
    output = phlex { RubyUI.ContextMenuContent(side: :diagonal, align: :middle) }

    assert_match(/data-side="right"/, output)
    assert_match(/data-align="start"/, output)
  end

  # `hidePopover` runs after the animation ends; without a forwards fill mode that frame flashes.
  def test_content_holds_the_last_frame_of_the_exit_animation
    output = phlex { RubyUI.ContextMenuContent { RubyUI.ContextMenuItem { "Back" } } }

    assert_match(/data-closed:fill-mode-forwards/, output)
    assert_match(/duration-100/, output)
    assert_match(/origin-\(--transform-origin\)/, output)
  end

  def test_trigger_is_not_selectable
    output = phlex { RubyUI.ContextMenuTrigger { "Right click here" } }

    assert_match(/class="select-none"/, output)
    assert_match(/contextmenu->ruby-ui--context-menu#handleContextMenu/, output)
  end

  def test_item_is_a_div_without_href
    output = phlex { RubyUI.ContextMenuItem { "Back" } }

    assert_match(/<div role="menuitem" tabindex="-1"/, output)
    refute_match(/href=/, output)
    refute_match(/\sdata-inset[\s=>]/, output)
  end

  def test_item_with_href_is_a_link
    output = phlex { RubyUI.ContextMenuItem(href: "/history") { "History" } }

    assert_match(/<a href="\/history" role="menuitem"/, output)
  end

  def test_disabled_item_is_exposed_as_disabled
    output = phlex { RubyUI.ContextMenuItem(disabled: true) { "Forward" } }

    assert_match(/aria-disabled="true"/, output)
    assert_match(/data-disabled/, output)
    refute_match(/\sdisabled(=|\s|>)/, output)
  end

  def test_inset_item_and_label
    item = phlex { RubyUI.ContextMenuItem(inset: true) { "Back" } }
    label = phlex { RubyUI.ContextMenuLabel(inset: true) { "More Tools" } }

    assert_match(/data-inset/, item)
    assert_match(/data-inset/, label)
    assert_match(/data-inset:pl-8/, label)
    refute_match(/inset\?/, label)
  end

  def test_label_names_its_group
    output = phlex do
      RubyUI.ContextMenuGroup(id: "tools") do
        RubyUI.ContextMenuLabel { "More Tools" }
        RubyUI.ContextMenuItem { "Developer Tools" }
      end
    end

    assert_match(/role="group"[^>]*aria-labelledby="tools-label"|aria-labelledby="tools-label"[^>]*role="group"/, output)
    assert_match(/<div aria-hidden="true"[^>]*id="tools-label"|id="tools-label"[^>]*aria-hidden="true"/, output)
  end

  def test_label_names_its_radio_group
    output = phlex do
      RubyUI.ContextMenuRadioGroup(id: "people") do
        RubyUI.ContextMenuLabel { "People" }
        RubyUI.ContextMenuRadioItem(value: "pedro") { "Pedro Duarte" }
      end
    end

    assert_match(/data-slot="context-menu-radio-group"/, output)
    assert_match(/aria-labelledby="people-label"/, output)
  end

  # Literal class names: Tailwind only generates what it finds in the source.
  def test_indicators_show_only_when_checked
    checkbox = phlex { RubyUI.ContextMenuCheckboxItem(checked: true) { "Bookmarks" } }
    radio = phlex { RubyUI.ContextMenuRadioItem(value: "a") { "A" } }

    assert_match(/group\/context-menu-checkbox-item .*group-aria-checked\/context-menu-checkbox-item:flex/m, checkbox)
    assert_match(/group\/context-menu-radio-item .*group-aria-checked\/context-menu-radio-item:flex/m, radio)
  end

  def test_label_outside_a_group_stays_visible_to_assistive_tech
    output = phlex { RubyUI.ContextMenuLabel { "More Tools" } }

    refute_match(/aria-hidden/, output)
  end

  # checked: false was the old default: it stays a plain item (and keeps its link).
  def test_unchecked_item_stays_a_plain_link
    output = phlex { RubyUI.ContextMenuItem(href: "/history", checked: false) { "History" } }

    assert_match(/<a href="\/history" role="menuitem"/, output)
    refute_match(/menuitemcheckbox/, output)
  end

  def test_checked_item_renders_a_checkbox_item
    output = phlex { RubyUI.ContextMenuItem(checked: true, shortcut: "⌘⇧B") { "Show Bookmarks Bar" } }

    assert_match(/role="menuitemcheckbox"/, output)
    assert_match(/aria-checked="true"/, output)
    assert_match(/data-slot="context-menu-item-indicator"/, output)
    assert_match(/⌘⇧B/, output)
  end
end
