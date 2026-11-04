# frozen_string_literal: true

require "test_helper"

class RubyUI::SidebarTest < ComponentTest
  def test_render_with_all_items
    output = phlex do
      RubyUI.SidebarWrapper do
        RubyUI.Sidebar do
          RubyUI.SidebarHeader do
            RubyUI.SidebarGroup do
              RubyUI.SidebarGroupContent do
                RubyUI.SidebarInput(id: "search", placeholder: "Search the docs")
              end
            end
          end
          RubyUI.SidebarContent do
            RubyUI.SidebarGroup do
              RubyUI.SidebarGroupLabel { "Application" }
              RubyUI.SidebarGroupAction { "Group Action" }
              RubyUI.SidebarGroupContent do
                RubyUI.SidebarMenu do
                  RubyUI.SidebarMenuItem do
                    RubyUI.SidebarMenuSub do
                      RubyUI.SidebarMenuSubItem do
                        RubyUI.SidebarMenuSubButton(as: :a, href: "#") { "Sub Item 1" }
                      end
                    end
                  end
                  RubyUI.SidebarMenuItem do
                    RubyUI.SidebarMenuButton(as: :a, href: "#") { "Settings" }
                    RubyUI.SidebarMenuAction { "Settings" }
                  end
                  RubyUI.SidebarMenuItem do
                    RubyUI.SidebarMenuButton { "Dashboard" }
                    RubyUI.SidebarMenuAction { "Dashboard" }
                    RubyUI.SidebarMenuBadge { "Dashboard Badge" }
                  end
                  RubyUI.SidebarMenuItem do
                    RubyUI.SidebarMenuSkeleton()
                  end
                end
              end
            end
            RubyUI.SidebarSeparator()
          end
          RubyUI.SidebarFooter { "Footer" }
          RubyUI.SidebarRail()
        end
        RubyUI.SidebarInset do
          RubyUI.SidebarTrigger()
        end
      end
    end

    assert_match(/Search the docs/, output)
    assert_match(/Application/, output)
    assert_match(/Group Action/, output)
    assert_match(/Sub Item 1/, output)
    assert_match(/Settings/, output)
    assert_match(/Dashboard/, output)
    assert_match(/Dashboard Badge/, output)
    assert_match(/Footer/, output)
  end

  def test_render_non_collapsible_sidebar
    output = phlex do
      RubyUI.SidebarWrapper do
        RubyUI.Sidebar(collapsible: :none) do
          RubyUI.SidebarHeader do
            RubyUI.SidebarGroup do
              RubyUI.SidebarGroupContent do
                RubyUI.SidebarInput(id: "search", placeholder: "Search the docs")
              end
            end
          end
          RubyUI.SidebarContent do
            RubyUI.SidebarGroup do
              RubyUI.SidebarGroupLabel { "Application" }
              RubyUI.SidebarGroupAction { "Group Action" }
              RubyUI.SidebarGroupContent do
                RubyUI.SidebarMenu do
                  RubyUI.SidebarMenuItem do
                    RubyUI.SidebarMenuSub do
                      RubyUI.SidebarMenuSubItem do
                        RubyUI.SidebarMenuSubButton(as: :a, href: "#") { "Sub Item 1" }
                      end
                    end
                  end
                  RubyUI.SidebarMenuItem do
                    RubyUI.SidebarMenuButton(as: :a, href: "#") { "Settings" }
                    RubyUI.SidebarMenuAction { "Settings" }
                  end
                  RubyUI.SidebarMenuItem do
                    RubyUI.SidebarMenuButton { "Dashboard" }
                    RubyUI.SidebarMenuAction { "Dashboard" }
                    RubyUI.SidebarMenuBadge { "Dashboard Badge" }
                  end
                  RubyUI.SidebarMenuItem do
                    RubyUI.SidebarMenuSkeleton()
                  end
                end
              end
            end
            RubyUI.SidebarSeparator()
          end
          RubyUI.SidebarFooter { "Footer" }
          RubyUI.SidebarRail()
        end
        RubyUI.SidebarInset do
          RubyUI.SidebarTrigger()
        end
      end
    end

    assert_match(/Search the docs/, output)
    assert_match(/Application/, output)
    assert_match(/Group Action/, output)
    assert_match(/Sub Item 1/, output)
    assert_match(/Settings/, output)
    assert_match(/Dashboard/, output)
    assert_match(/Dashboard Badge/, output)
    assert_match(/Footer/, output)
  end

  def test_with_side_right
    output = phlex do
      RubyUI.Sidebar(side: :right)
    end

    assert_match(/data-side="right"/, output)
  end

  def test_with_variant_floating
    output = phlex do
      RubyUI.Sidebar(variant: :floating)
    end

    assert_match(/data-variant="floating"/, output)
  end

  def test_with_collapsible_icon
    output = phlex do
      RubyUI.Sidebar(collapsible: :icon)
    end

    assert_match(/data-collapsible-kind="icon"/, output)
  end

  def test_with_open_false
    output = phlex do
      RubyUI.Sidebar(open: false)
    end

    assert_match(/data-state="collapsed"/, output)
  end

  def test_with_collapsible_offcanvas
    output = phlex do
      RubyUI.Sidebar(collapsible: :offcanvas)
    end

    assert_match(/data-collapsible-kind="offcanvas"/, output)
  end

  def test_menu_item_renders_li
    output = phlex { RubyUI.SidebarMenu { RubyUI.SidebarMenuItem { "Home" } } }

    assert_match(%r{<ul class="[^"]*" data-slot="sidebar-menu" data-sidebar="menu"><li class="[^"]*" data-slot="sidebar-menu-item"}, output)
  end

  def test_menu_sub_item_has_slot
    output = phlex { RubyUI.SidebarMenuSubItem { "Design" } }

    assert_match(%r{<li[^>]*data-slot="sidebar-menu-sub-item"}, output)
  end

  def test_rail_is_named_and_not_tabbable
    output = phlex { RubyUI.SidebarRail() }

    assert_match(/tabindex="-1"/, output)
    assert_match(/aria-label="Toggle Sidebar"/, output)
    assert_match(/title="Toggle Sidebar"/, output)
    refute_match(/data-tabindex/, output)
  end

  def test_trigger_is_icon_sm_with_hidden_icon
    output = phlex { RubyUI.SidebarTrigger(data: {testid: "toggle"}) }

    assert_match(/data-slot="sidebar-trigger"/, output)
    refute_match(/data-slot="button/, output)
    assert_match(/h-8 w-8/, output)
    assert_match(/aria-hidden="true"/, output)
  end

  def test_sidebar_parts_have_data_slot
    output = phlex do
      RubyUI.SidebarWrapper do
        RubyUI.Sidebar(collapsible: :icon) do
          RubyUI.SidebarHeader { RubyUI.SidebarInput(placeholder: "Search") }
          RubyUI.SidebarSeparator()
          RubyUI.SidebarContent { RubyUI.SidebarGroup { RubyUI.SidebarGroupLabel { "Label" } } }
          RubyUI.SidebarFooter { "Footer" }
        end
        RubyUI.SidebarInset { "Main" }
      end
    end

    %w[sidebar-wrapper sidebar sidebar-gap sidebar-container sidebar-inner sidebar-header sidebar-input
      sidebar-separator sidebar-content sidebar-group sidebar-group-label sidebar-footer sidebar-inset].each do |slot|
      assert_match(/data-slot="#{slot}"/, output)
    end
  end

  def test_sidebar_attrs_go_to_container
    output = phlex { RubyUI.Sidebar(class: "custom-width") }

    assert_match(%r{<div class="[^"]*custom-width[^"]*"[^>]*data-slot="sidebar-container"}, output)
    refute_match(/class="group peer[^"]*custom-width/, output)
  end

  def test_non_collapsible_sidebar_reports_expanded_state
    output = phlex { RubyUI.Sidebar(collapsible: :none) }

    assert_match(/data-slot="sidebar" data-state="expanded"/, output)
  end

  def test_container_carries_side
    output = phlex { RubyUI.Sidebar(side: :right) }

    assert_match(/data-slot="sidebar-container" data-side="right"/, output)
  end

  def test_invalid_variant_raises_argument_error
    assert_raises(ArgumentError) { phlex { RubyUI.Sidebar(variant: :bogus) } }
  end

  def test_menu_action_show_on_hover
    output = phlex { RubyUI.SidebarMenuAction(show_on_hover: true) { "More" } }

    assert_match(/md:opacity-0/, output)
    assert_match(/aria-expanded:opacity-100/, output)
  end

  def test_menu_action_without_show_on_hover
    output = phlex { RubyUI.SidebarMenuAction { "More" } }

    refute_match(/md:opacity-0/, output)
  end

  def test_menu_button_outline_uses_css_variable
    output = phlex { RubyUI.SidebarMenuButton(variant: :outline) { "Home" } }

    assert_match(/shadow-\[0_0_0_1px_var\(--sidebar-border\)\]/, output)
    refute_match(/hsl\(var/, output)
  end

  def test_menu_button_tooltip
    output = phlex { RubyUI.SidebarMenuButton(tooltip: "Home") { "Home" } }

    assert_match(/data-controller="ruby-ui--tooltip"/, output)
    assert_match(/data-ruby-ui--tooltip-target="trigger"><template data-ruby-ui--tooltip-target="content">/, output)
    assert_match(/data-preferred-side="right"/, output)
    refute_match(/data-action/, output)
  end

  # Each tooltip hides from its own sidebar's state, not from any expanded
  # sidebar on the page (two sidebars on one page).
  def test_menu_button_tooltip_hides_from_its_own_sidebar
    output = phlex { RubyUI.SidebarMenuButton(tooltip: "Home") { "Home" } }

    assert_includes output, "[[data-slot=sidebar]:not([data-state=collapsed])_&]:hidden"
    assert_includes output, "max-md:hidden"
    refute_match(/body:has/, output)
  end

  def test_menu_button_without_tooltip
    output = phlex { RubyUI.SidebarMenuButton { "Home" } }

    refute_match(/ruby-ui--tooltip/, output)
  end

  def test_menu_sub_button_defaults_to_link
    output = phlex { RubyUI.SidebarMenuSubButton(href: "#") { "Design" } }

    assert_match(%r{\A<a .*href="#">Design</a>\z}, output)
  end

  def test_group_label_as
    output = phlex { RubyUI.SidebarGroupLabel(as: :button) { "Projects" } }

    assert_match(%r{\A<button .*data-slot="sidebar-group-label"}, output)
  end

  def test_wrapper_keyboard_shortcut
    output = phlex { RubyUI.SidebarWrapper { "content" } }

    assert_match(/keydown\.ctrl\+b@window->ruby-ui--sidebar#toggle/, output)
    assert_match(/keydown\.meta\+b@window->ruby-ui--sidebar#toggle/, output)
  end

  # On mobile the sidebar is a Sheet: a native <dialog> (role=dialog, focus moved
  # in by showModal, Esc closes) named by its sr-only title, with no close button.
  def test_mobile_sidebar_is_a_sheet_dialog
    output = phlex do
      RubyUI.MobileSidebar { "menu" }
    end

    assert_match(/<dialog[^>]*data-ruby-ui--sheet-target="content"/, output)
    assert_match(/<h2[^>]*data-ruby-ui--sheet-target="title"[^>]*>Sidebar<\/h2>/, output)
    assert_includes output, %(data-side="left")
    assert_includes output, "w-[var(--sidebar-width)]"
    refute_includes output, "w-3/4"
    refute_includes output, %(data-slot="sheet-close")
    assert_includes output, "ruby--ui-sidebar:open->ruby-ui--sheet#open:self"
  end

  def test_separator_is_semantic_with_its_own_slot
    output = phlex { RubyUI.SidebarSeparator() }

    assert_match(/role="separator"/, output)
    assert_match(/data-slot="sidebar-separator"/, output)
    refute_match(/data-slot="separator /, output)
  end

  def test_mobile_sheet_content_slot_is_sidebar
    output = phlex { RubyUI.MobileSidebar { "menu" } }

    assert_match(/<dialog data-slot="sidebar"/, output)
  end
end
