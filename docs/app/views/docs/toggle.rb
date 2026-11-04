# frozen_string_literal: true

class Views::Docs::Toggle < Views::Base
  def view_template
    component = "Toggle"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(
        title: "Toggle",
        description: "A two-state button that can be either on or off."
      )

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Default", context: self) do
        <<~RUBY
          Toggle { "Bold" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Outline", context: self) do
        <<~RUBY
          Toggle(variant: :outline) { "Italic" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "With Icon", description: "Icon-only toggles need an aria-label. Mark an icon next to text with data-icon=\"inline-start\" or \"inline-end\" so the toggle tightens the padding on that side.", context: self) do
        <<~RUBY
          div(class: "flex items-center gap-2") do
            Toggle(aria: {label: "Toggle bold"}) do
              svg(xmlns: "http://www.w3.org/2000/svg", width: "24", height: "24", viewbox: "0 0 24 24", fill: "none",
                stroke: "currentColor", stroke_width: "2", stroke_linecap: "round", stroke_linejoin: "round", aria_hidden: "true") do |s|
                s.path(d: "M6 12h9a4 4 0 0 1 0 8H7a1 1 0 0 1-1-1V5a1 1 0 0 1 1-1h7a4 4 0 0 1 0 8")
              end
            end
            Toggle(variant: :outline) do
              svg(xmlns: "http://www.w3.org/2000/svg", width: "24", height: "24", viewbox: "0 0 24 24", fill: "none",
                stroke: "currentColor", stroke_width: "2", stroke_linecap: "round", stroke_linejoin: "round", aria_hidden: "true",
                data: {icon: "inline-start"}) do |s|
                s.line(x1: "19", x2: "10", y1: "4", y2: "4")
                s.line(x1: "14", x2: "5", y1: "20", y2: "20")
                s.line(x1: "15", x2: "9", y1: "4", y2: "20")
              end
              plain "Italic"
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Sizes", context: self) do
        <<~RUBY
          div(class: "flex items-center gap-2") do
            Toggle(size: :sm) { "Small" }
            Toggle(size: :default) { "Default" }
            Toggle(size: :lg) { "Large" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Pressed", context: self) do
        <<~RUBY
          Toggle(pressed: true) { "Pressed" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Disabled", context: self) do
        <<~RUBY
          Toggle(disabled: true) { "Disabled" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "In a form", context: self) do
        <<~RUBY
          Toggle(name: "bold", value: "1") { "Bold" }
        RUBY
      end

      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
