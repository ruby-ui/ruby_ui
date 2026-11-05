# frozen_string_literal: true

class Views::Docs::Link < Views::Base
  def view_template
    component = "Link"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Link", description: "Displays a link that looks like a button or an underlined text link.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Example", description: "A Link looks like a primary button by default, but stays a native link: screen readers announce a link and Enter follows it.", context: self) do
        <<~RUBY
          Link(href: "#") { "Get started" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Link", description: "An underlined text link", context: self) do
        <<~RUBY
          Link(href: "#", variant: :link) { "Read the docs" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Disabled", description: "disabled: true removes the href, so the link can't be focused or followed. Add focusable_when_disabled: true to keep it in the tab order (e.g. for a tooltip).", context: self) do
        <<~RUBY
          div(class: "flex gap-2") do
            Link(href: "#", disabled: true) { "Disabled" }
            Link(href: "#", disabled: true, focusable_when_disabled: true) { "Focusable" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Secondary", description: "This is the secondary variant of a Link", context: self) do
        <<~RUBY
          Link(href: "#", variant: :secondary) { "Secondary" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Destructive", description: "This is the destructive variant of a Link", context: self) do
        <<~RUBY
          Link(href: "#", variant: :destructive) { "Destructive" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Outline", description: "This is the outline variant of a Link", context: self) do
        <<~RUBY
          Link(href: "#", variant: :outline) { "Outline" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Sizes", context: self) do
        <<~RUBY
          div(class: "flex items-center gap-2") do
            Link(href: "#", size: :xs) { "Extra small" }
            Link(href: "#", size: :sm) { "Small" }
            Link(href: "#") { "Default" }
            Link(href: "#", size: :lg) { "Large" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Icon", description: "This is the icon variant of a Link", context: self) do
        <<~RUBY
          Link(href: "#", variant: :outline, icon: true) do
            chevron_icon
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "With Icon", description: "This is the primary variant of a Link with an icon", context: self) do
        <<~RUBY
          Link(href: "#") do
            email_icon
            span { "Login with Email" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Ghost", description: "This is the ghost variant of a Link", context: self) do
        <<~RUBY
          Link(href: "#", variant: :ghost) { "Ghost" }
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end

  private

  def chevron_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      viewbox: "0 0 20 20",
      fill: "currentColor"
    ) do |s|
      s.path(
        fill_rule: "evenodd",
        d:
          "M7.21 14.77a.75.75 0 01.02-1.06L11.168 10 7.23 6.29a.75.75 0 111.04-1.08l4.5 4.25a.75.75 0 010 1.08l-4.5 4.25a.75.75 0 01-1.06-.02z",
        clip_rule: "evenodd"
      )
    end
  end

  def email_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      fill: "none",
      viewbox: "0 0 24 24",
      stroke_width: "1.5",
      stroke: "currentColor",
      data: {icon: "inline-start"}
    ) do |s|
      s.path(
        stroke_linecap: "round",
        stroke_linejoin: "round",
        d:
          "M21.75 6.75v10.5a2.25 2.25 0 01-2.25 2.25h-15a2.25 2.25 0 01-2.25-2.25V6.75m19.5 0A2.25 2.25 0 0019.5 4.5h-15a2.25 2.25 0 00-2.25 2.25m19.5 0v.243a2.25 2.25 0 01-1.07 1.916l-7.5 4.615a2.25 2.25 0 01-2.36 0L3.32 8.91a2.25 2.25 0 01-1.07-1.916V6.75"
      )
    end
  end
end
