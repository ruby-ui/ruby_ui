# frozen_string_literal: true

class Views::Docs::Badge < Views::Base
  def view_template
    component = "Badge"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Badge", description: "Displays a badge or a component that looks like a badge.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Default", context: self) do
        <<~RUBY
          Badge { "Badge" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Secondary", context: self) do
        <<~RUBY
          Badge(variant: :secondary) { "Secondary" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Destructive", context: self) do
        <<~RUBY
          Badge(variant: :destructive) { "Destructive" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Outline", context: self) do
        <<~RUBY
          Badge(variant: :outline) { "Outline" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Ghost", context: self) do
        <<~RUBY
          Badge(variant: :ghost) { "Ghost" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Link", context: self) do
        <<~RUBY
          Badge(variant: :link, href: "#") { "Link" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "With Icon", description: "Mark the icon with data-icon=\"inline-start\" or \"inline-end\" so the badge tightens the padding on that side. Icons are sized to 12px.", context: self) do
        <<~RUBY
          div(class: "flex flex-wrap gap-2 justify-center") do
            Badge(variant: :secondary) do
              svg(xmlns: "http://www.w3.org/2000/svg", width: "24", height: "24", viewbox: "0 0 24 24", fill: "none",
                stroke: "currentColor", stroke_width: "2", stroke_linecap: "round", stroke_linejoin: "round",
                aria_hidden: "true", data: {icon: "inline-start"}) do |s|
                s.path(d: "M3.85 8.62a4 4 0 0 1 4.78-4.77 4 4 0 0 1 6.74 0 4 4 0 0 1 4.78 4.78 4 4 0 0 1 0 6.74 4 4 0 0 1-4.77 4.78 4 4 0 0 1-6.75 0 4 4 0 0 1-4.78-4.77 4 4 0 0 1 0-6.76Z")
                s.path(d: "m9 12 2 2 4-4")
              end
              plain "Verified"
            end
            Badge(variant: :outline) do
              plain "Bookmark"
              svg(xmlns: "http://www.w3.org/2000/svg", width: "24", height: "24", viewbox: "0 0 24 24", fill: "none",
                stroke: "currentColor", stroke_width: "2", stroke_linecap: "round", stroke_linejoin: "round",
                aria_hidden: "true", data: {icon: "inline-end"}) do |s|
                s.path(d: "m19 21-7-4-7 4V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2v16z")
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "As Link", description: "Pass href: to render an <a>. Links get the variant's hover color and a focus ring.", context: self) do
        <<~RUBY
          Badge(href: "#") do
            plain "Open Link"
            svg(xmlns: "http://www.w3.org/2000/svg", width: "24", height: "24", viewbox: "0 0 24 24", fill: "none",
              stroke: "currentColor", stroke_width: "2", stroke_linecap: "round", stroke_linejoin: "round",
              aria_hidden: "true", data: {icon: "inline-end"}) do |s|
              s.path(d: "M7 7h10v10")
              s.path(d: "M7 17 17 7")
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Status Colors", context: self) do
        <<~RUBY
          div(class: "flex flex-wrap gap-2 justify-center") do
            Badge(variant: :success) { "Success" }
            Badge(variant: :warning) { "Warning" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Other Colors", context: self) do
        <<~RUBY
          div(class: "flex flex-wrap gap-2 justify-center") do
            Badge(variant: :red) { "Red" }
            Badge(variant: :orange) { "Orange" }
            Badge(variant: :amber) { "Amber" }
            Badge(variant: :yellow) { "Yellow" }
            Badge(variant: :lime) { "Lime" }
            Badge(variant: :green) { "Green" }
            Badge(variant: :emerald) { "Emerald" }
            Badge(variant: :teal) { "Teal" }
            Badge(variant: :cyan) { "Cyan" }
            Badge(variant: :sky) { "Sky" }
            Badge(variant: :blue) { "Blue" }
            Badge(variant: :indigo) { "Indigo" }
            Badge(variant: :violet) { "Violet" }
            Badge(variant: :purple) { "Purple" }
            Badge(variant: :fuchsia) { "Fuchsia" }
            Badge(variant: :pink) { "Pink" }
            Badge(variant: :rose) { "Rose" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Sizes", context: self) do
        <<~RUBY
          div(class: "flex flex-wrap gap-2 justify-center items-center") do
            Badge(size: :sm) { "Small" }
            Badge(size: :md) { "Medium" }
            Badge(size: :lg) { "Large" }
          end
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      # components
      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
