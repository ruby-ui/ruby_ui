# frozen_string_literal: true

class Docs::LinkView < ApplicationView
  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-8") do
      div(class: 'space-y-2') do
        render Typography::H1.new { "Link" }
        render Typography::P.new { "Displays a link that looks like a button or underline link." }
      end

      render Docs::VisualCodeExample.new(title: "Default", description: "This is the default appearance of a Link") do
        render Link.new(href: "#") { "Link" }
      end

      render Docs::VisualCodeExample.new(title: "Primary", description: "This is the primary variant of a Link") do
        render Link.new(href: "#", variant: :primary) { "Primary" }
      end

      render Docs::VisualCodeExample.new(title: "Secondary", description: "This is the secondary variant of a Link") do
        render Link.new(href: "#", variant: :secondary) { "Secondary" }
      end

      render Docs::VisualCodeExample.new(title: "Destructive", description: "This is the destructive variant of a Link") do
        render Link.new(href: "#", variant: :destructive) { "Destructive" }
      end

      render Docs::VisualCodeExample.new(title: "Icon", description: "This is the icon variant of a Link") do
        render Link.new(href: "#", variant: :outline, size: :icon) do 
          svg(
            xmlns: "http://www.w3.org/2000/svg",
            viewbox: "0 0 20 20",
            fill: "currentColor",
            class: "w-5 h-5"
          ) do |s|
            s.path(
              fill_rule: "evenodd",
              d:
                "M7.21 14.77a.75.75 0 01.02-1.06L11.168 10 7.23 6.29a.75.75 0 111.04-1.08l4.5 4.25a.75.75 0 010 1.08l-4.5 4.25a.75.75 0 01-1.06-.02z",
              clip_rule: "evenodd"
            )
          end
        end
      end

      render Docs::VisualCodeExample.new(title: "With Icon", description: "This is the primary variant of a Link with an icon") do
        render Link.new(href: "#", variant: :primary) do 
          svg(
            xmlns: "http://www.w3.org/2000/svg",
            fill: "none",
            viewbox: "0 0 24 24",
            stroke_width: "1.5",
            stroke: "currentColor",
            class: "w-4 h-4 mr-2"
          ) do |s|
            s.path(
              stroke_linecap: "round",
              stroke_linejoin: "round",
              d:
                "M21.75 6.75v10.5a2.25 2.25 0 01-2.25 2.25h-15a2.25 2.25 0 01-2.25-2.25V6.75m19.5 0A2.25 2.25 0 0019.5 4.5h-15a2.25 2.25 0 00-2.25 2.25m19.5 0v.243a2.25 2.25 0 01-1.07 1.916l-7.5 4.615a2.25 2.25 0 01-2.36 0L3.32 8.91a2.25 2.25 0 01-1.07-1.916V6.75"
            )
          end
          span { "Login with Email" }
        end
      end

      render Docs::VisualCodeExample.new(title: "Ghost", description: "This is the ghost variant of a Link") do
        render Link.new(href: "#", variant: :ghost) { "Ghost" }
      end
    end
  end
end
