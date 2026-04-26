# frozen_string_literal: true

class Views::Docs::Sidebar::Example < Views::Base
  FAVORITES = [
    {name: "Project Management & Task Tracking", emoji: "📊"},
    {name: "Movies & TV Shows", emoji: "🎬"},
    {name: "Books & Articles", emoji: "📚"},
    {name: "Recipes & Meal Planning", emoji: "🍽️"},
    {name: "Travel & Places", emoji: "🌍"},
    {name: "Health & Fitness", emoji: "🏋️"}
  ].freeze

  WORKSPACES = [
    {name: "Personal Life Management", emoji: "🏡"},
    {name: "Work & Projects", emoji: "💼"},
    {name: "Side Projects", emoji: "🚀"},
    {name: "Learning & Courses", emoji: "📚"},
    {name: "Writing & Blogging", emoji: "📝"},
    {name: "Design & Development", emoji: "🎨"}
  ].freeze

  def initialize(sidebar_state:)
    @sidebar_state = sidebar_state
  end

  CODE = <<~RUBY
    SidebarWrapper do
      Sidebar(collapsible: :icon) do
        SidebarHeader do
          SidebarMenu do
            SidebarMenuItem do
              SidebarMenuButton(as: :a, href: "#") do
                search_icon()
                span { "Search" }
              end
            end
            SidebarMenuItem do
              SidebarMenuButton(as: :a, href: "#", active: true) do
                home_icon()
                span { "Home" }
              end
            end
            SidebarMenuItem do
              SidebarMenuButton(as: :a, href: "#") do
                inbox_icon()
                span { "Inbox" }
                SidebarMenuBadge { 4 }
              end
            end
          end
        end
        SidebarContent do
          SidebarGroup do
            SidebarGroupLabel { "Favorites" }
            SidebarMenu do
              FAVORITES.each do |item|
                SidebarMenuItem do
                  SidebarMenuButton(as: :a, href: "#") do
                    span { item[:emoji] }
                    span { item[:name] }
                  end
                  DropdownMenu(options: { strategy: "fixed", placement: "right-start" }) do
                    SidebarMenuAction(
                      data: {
                        ruby_ui__dropdown_menu_target: "trigger",
                        action: "click->ruby-ui--dropdown-menu#toggle"
                      }
                    ) do
                      ellipsis_icon()
                      span(class: "sr-only") { "More" }
                    end
                    DropdownMenuContent do
                      DropdownMenuItem(href: '#') { "Profile" }
                      DropdownMenuItem(href: '#') { "Billing" }
                      DropdownMenuItem(href: '#') { "Team" }
                      DropdownMenuItem(href: '#') { "Subscription" }
                    end
                  end
                end
              end
            end
          end
          SidebarGroup do
            SidebarGroupLabel { "Workspaces" }
            SidebarMenu do
              WORKSPACES.each do |item|
                SidebarMenuItem do
                  SidebarMenuButton(as: :a, href: "#") do
                    span { item[:emoji] }
                    span { item[:name] }
                  end
                  DropdownMenu() do
                    SidebarMenuAction(
                      data: {
                        ruby_ui__dropdown_menu_target: "trigger",
                        action: "click->ruby-ui--dropdown-menu#toggle"
                      }
                    ) do
                      ellipsis_icon()
                      span(class: "sr-only") { "More" }
                    end
                    DropdownMenuContent do
                      DropdownMenuItem(href: '#') { "Profile" }
                      DropdownMenuItem(href: '#') { "Billing" }
                      DropdownMenuItem(href: '#') { "Team" }
                      DropdownMenuItem(href: '#') { "Subscription" }
                    end
                  end
                end
              end
            end
          end
          SidebarGroup(class: "mt-auto") do
            SidebarGroupContent do
              SidebarMenu do
                nav_secondary.each do |item|
                  SidebarMenuItem do
                    SidebarMenuButton(as: :a, href: "#") do
                      item[:icon].call
                      span { item[:label] }
                    end
                  end
                end
              end
            end
          end
        end
        SidebarRail()
      end
      SidebarInset do
        header(class: "flex h-16 shrink-0 items-center gap-2 border-b px-4") do
          SidebarTrigger(class: "-ml-1")
        end
      end
    end
  RUBY

  def view_template
    decoded_code = CGI.unescapeHTML(CODE)
    instance_eval(decoded_code)
  end

  private

  def nav_secondary
    [
      {label: "Settings", icon: -> { settings_icon }},
      {label: "Help & Support", icon: -> { message_circle_question }}
    ]
  end

  def home_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      width: "24",
      height: "24",
      viewBox: "0 0 24 24",
      fill: "none",
      stroke: "currentColor",
      stroke_width: "2",
      stroke_linecap: "round",
      stroke_linejoin: "round",
      class: "lucide lucide-house"
    ) do |s|
      s.path(d: "M15 21v-8a1 1 0 0 0-1-1h-4a1 1 0 0 0-1 1v8")
      s.path(d: "M3 10a2 2 0 0 1 .709-1.528l7-5.999a2 2 0 0 1 2.582 0l7 5.999A2 2 0 0 1 21 10v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z")
    end
  end

  def inbox_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      width: "24",
      height: "24",
      viewBox: "0 0 24 24",
      fill: "none",
      stroke: "currentColor",
      stroke_width: "2",
      stroke_linecap: "round",
      stroke_linejoin: "round",
      class: "lucide lucide-inbox"
    ) do |s|
      s.polyline(points: "22 12 16 12 14 15 10 15 8 12 2 12")
      s.path(d: "M5.45 5.11 2 12v6a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2v-6l-3.45-6.89A2 2 0 0 0 16.76 4H7.24a2 2 0 0 0-1.79 1.11z")
    end
  end

  def calendar_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      width: "24",
      height: "24",
      viewBox: "0 0 24 24",
      fill: "none",
      stroke: "currentColor",
      stroke_width: "2",
      stroke_linecap: "round",
      stroke_linejoin: "round",
      class: "lucide lucide-calendar"
    ) do |s|
      s.path(d: "M8 2v4")
      s.path(d: "M16 2v4")
      s.rect(width: "18", height: "18", x: "3", y: "4", rx: "2")
      s.path(d: "M3 10h18")
    end
  end

  def search_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      width: "24",
      height: "24",
      viewBox: "0 0 24 24",
      fill: "none",
      stroke: "currentColor",
      stroke_width: "2",
      stroke_linecap: "round",
      stroke_linejoin: "round",
      class: "lucide lucide-search"
    ) do |s|
      s.circle(cx: "11", cy: "11", r: "8")
      s.path(d: "M21 21L16.7 16.7")
    end
  end

  def settings_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      width: "24",
      height: "24",
      viewBox: "0 0 24 24",
      fill: "none",
      stroke: "currentColor",
      stroke_width: "2",
      stroke_linecap: "round",
      stroke_linejoin: "round",
      class: "lucide lucide-settings"
    ) do |s|
      s.path(d: "M12.22 2h-.44a2 2 0 0 0-2 2v.18a2 2 0 0 1-1 1.73l-.43.25a2 2 0 0 1-2 0l-.15-.08a2 2 0 0 0-2.73.73l-.22.38a2 2 0 0 0 .73 2.73l.15.1a2 2 0 0 1 1 1.72v.51a2 2 0 0 1-1 1.74l-.15.09a2 2 0 0 0-.73 2.73l.22.38a2 2 0 0 0 2.73.73l.15-.08a2 2 0 0 1 2 0l.43.25a2 2 0 0 1 1 1.73V20a2 2 0 0 0 2 2h.44a2 2 0 0 0 2-2v-.18a2 2 0 0 1 1-1.73l.43-.25a2 2 0 0 1 2 0l.15.08a2 2 0 0 0 2.73-.73l.22-.39a2 2 0 0 0-.73-2.73l-.15-.08a2 2 0 0 1-1-1.74v-.5a2 2 0 0 1 1-1.74l.15-.09a2 2 0 0 0 .73-2.73
      l-.22-.38a2 2 0 0 0-2.73-.73l-.15.08a2 2 0 0 1-2 0l-.43-.25a2 2 0 0 1-1-1.73V4a2 2 0 0 0-2-2z")
      s.circle(cx: "12", cy: "12", r: "3")
    end
  end

  def plus_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      width: "24",
      height: "24",
      viewBox: "0 0 24 24",
      fill: "none",
      stroke: "currentColor",
      stroke_width: "2",
      stroke_linecap: "round",
      stroke_linejoin: "round",
      class: "lucide lucide-plus"
    ) do |s|
      s.path(d: "M5 12h14")
      s.path(d: "M12 5v14")
    end
  end

  def gallery_vertical_end
    svg(xmlns: "http://www.w3.org/2000/svg", width: "24", height: "24", view_box: "0 0 24 24", fill: "none", stroke: "currentColor", stroke_width: "2", stroke_linecap: "round", stroke_linejoin: "round", class: "lucide lucide-gallery-vertical-end size-4") do |s|
      s.path d: "M7 2h10"
      s.path d: "M5 6h14"
      s.rect width: "18", height: "12", x: "3", y: "10", rx: "2"
    end
  end

  def ellipsis_icon
    svg(xmlns: "http://www.w3.org/2000/svg", width: "24", height: "24", viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", stroke_width: "2", stroke_linecap: "round", stroke_line_join: "round", class: "lucide lucide-ellipsis-icon lucide-ellipsis") do |s|
      s.circle cx: "12", cy: "12", r: "1"
      s.circle cx: "19", cy: "12", r: "1"
      s.circle cx: "5", cy: "12", r: "1"
    end
  end

  def message_circle_question
    svg(xmlns: "http://www.w3.org/2000/svg", width: "24", height: "24", viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", stroke_width: "2", stroke_linecap: "round", stroke_line_join: "round", class: "lucide lucide-message-circle-question-icon lucide-message-circle-question") do |s|
      s.path d: "M7.9 20A9 9 0 1 0 4 16.1L2 22Z"
      s.path d: "M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"
      s.path d: "M12 17h.01"
    end
  end
end
