# frozen_string_literal: true

module ShadcnAuditFixtures
  # RubyUI side of audit/fixtures/sidebar (strings in content.yml).
  # Icons are lucide's (lucide-react 1.67) as lucide-react renders them
  # (24x24, aria-hidden, no size class), so both sides get the same SVG.
  class Sidebar < Phlex::HTML
    include RubyUI

    def view_template
      SidebarWrapper do
        Sidebar(collapsible: :icon) do
          SidebarHeader do
            SidebarInput(placeholder: "Search the docs")
          end
          SidebarSeparator()
          SidebarContent do
            SidebarGroup do
              SidebarGroupLabel { "Platform" }
              SidebarGroupAction do
                lucide_icon { |s| plus(s) }
                span(class: "sr-only") { "Add project" }
              end
              SidebarGroupContent do
                SidebarMenu do
                  SidebarMenuItem do
                    SidebarMenuButton(active: true) do
                      lucide_icon { |s| house(s) }
                      span { "Home" }
                    end
                  end
                  SidebarMenuItem do
                    SidebarMenuButton do
                      lucide_icon { |s| inbox(s) }
                      span { "Inbox" }
                    end
                    SidebarMenuBadge { "24" }
                  end
                  SidebarMenuItem do
                    SidebarMenuButton do
                      lucide_icon { |s| search(s) }
                      span { "Search" }
                    end
                    SidebarMenuAction do
                      lucide_icon { |s| ellipsis(s) }
                      span(class: "sr-only") { "More" }
                    end
                  end
                  SidebarMenuItem do
                    SidebarMenuButton do
                      lucide_icon { |s| folder(s) }
                      span { "Projects" }
                    end
                    SidebarMenuSub do
                      SidebarMenuSubItem do
                        SidebarMenuSubButton(as: :a, href: "#", active: true) { span { "Design" } }
                      end
                      SidebarMenuSubItem do
                        SidebarMenuSubButton(as: :a, href: "#") { span { "Marketing" } }
                      end
                    end
                  end
                end
              end
            end
          end
          SidebarFooter do
            SidebarMenu do
              SidebarMenuItem do
                SidebarMenuButton do
                  lucide_icon { |s| user(s) }
                  span { "Account" }
                end
              end
            end
          end
          SidebarRail()
        end
        SidebarInset do
          header(class: "flex h-12 items-center gap-2 px-4") do
            SidebarTrigger(data: {audit_trigger: true})
            span { "Dashboard" }
          end
          div(class: "p-4") do
            p { "Main content" }
          end
        end
      end
    end

    private

    def lucide_icon(&)
      svg(xmlns: "http://www.w3.org/2000/svg", width: "24", height: "24", viewbox: "0 0 24 24", fill: "none",
        stroke: "currentColor", stroke_width: "2", stroke_linecap: "round", stroke_linejoin: "round", aria_hidden: "true", &)
    end

    def plus(s)
      s.path(d: "M5 12h14")
      s.path(d: "M12 5v14")
    end

    def house(s)
      s.path(d: "M15 21v-8a1 1 0 0 0-1-1h-4a1 1 0 0 0-1 1v8")
      s.path(d: "M3 10a2 2 0 0 1 .709-1.528l7-6a2 2 0 0 1 2.582 0l7 6A2 2 0 0 1 21 10v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z")
    end

    def inbox(s)
      s.polyline(points: "22 12 16 12 14 15 10 15 8 12 2 12")
      s.path(d: "M5.45 5.11 2 12v6a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2v-6l-3.45-6.89A2 2 0 0 0 16.76 4H7.24a2 2 0 0 0-1.79 1.11z")
    end

    def search(s)
      s.path(d: "m21 21-4.34-4.34")
      s.circle(cx: "11", cy: "11", r: "8")
    end

    def ellipsis(s)
      s.circle(cx: "12", cy: "12", r: "1")
      s.circle(cx: "19", cy: "12", r: "1")
      s.circle(cx: "5", cy: "12", r: "1")
    end

    def folder(s)
      s.path(d: "M20 20a2 2 0 0 0 2-2V8a2 2 0 0 0-2-2h-7.9a2 2 0 0 1-1.69-.9L9.6 3.9A2 2 0 0 0 7.93 3H4a2 2 0 0 0-2 2v13a2 2 0 0 0 2 2Z")
    end

    def user(s)
      s.path(d: "M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2")
      s.circle(cx: "12", cy: "7", r: "4")
    end
  end
end
