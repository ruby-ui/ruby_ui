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
end
