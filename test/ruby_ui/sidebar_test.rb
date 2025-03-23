# frozen_string_literal: true

require 'test_helper'

class RubyUI::SidebarTest < ComponentTest
  def test_render_with_all_items
    output = phlex do
      RubyUI.SidebarWrapper do
        RubyUI.Sidebar do
          RubyUI.SidebarHeader do
            RubyUI.SidebarGroup do
              RubyUI.SidebarGroupContent do
                RubyUI.SidebarInput(id: 'search', placeholder: 'Search the docs')
              end
            end
          end
          RubyUI.SidebarContent do
            RubyUI.SidebarGroup do
              RubyUI.SidebarGroupLabel { 'Application' }
              RubyUI.SidebarGroupAction { 'Group Action' }
              RubyUI.SidebarGroupContent do
                RubyUI.SidebarMenu do
                  RubyUI.SidebarMenuItem do
                    RubyUI.SidebarMenuSub do
                      RubyUI.SidebarMenuSubItem do
                        RubyUI.SidebarMenuSubButton(as: 'a', href: '#') { 'Sub Item 1' }
                      end
                    end
                  end
                  RubyUI.SidebarMenuItem do
                    RubyUI.SidebarMenuButton(as: 'a', href: '#') { 'Settings' }
                    RubyUI.SidebarMenuAction { 'Settings' }
                  end
                  RubyUI.SidebarMenuItem do
                    RubyUI.SidebarMenuButton { 'Dashboard' }
                    RubyUI.SidebarMenuAction { 'Dashboard' }
                    RubyUI.SidebarMenuBadge { 'Dashboard Badge' }
                  end
                  RubyUI.SidebarMenuItem do
                    RubyUI.SidebarMenuSkeleton()
                  end
                end
              end
            end
          end
          RubyUI.SidebarFooter { 'Footer' }
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
end
