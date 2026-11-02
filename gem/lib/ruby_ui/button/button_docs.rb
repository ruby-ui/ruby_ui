# frozen_string_literal: true

class Views::Docs::Button < Views::Base
  def view_template
    component = "Button"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Button", description: "Displays a button or a component that looks like a button.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Default", context: self) do
        <<~RUBY
          Button { "Button" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Outline", context: self) do
        <<~RUBY
          Button(variant: :outline) { "Outline" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Secondary", context: self) do
        <<~RUBY
          Button(variant: :secondary) { "Secondary" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Ghost", context: self) do
        <<~RUBY
          Button(variant: :ghost) { "Ghost" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Destructive", context: self) do
        <<~RUBY
          Button(variant: :destructive) { "Destructive" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Link", context: self) do
        <<~RUBY
          Button(variant: :link) { "Link" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Sizes", description: "size: :xs, :sm, :md (the default), :lg and :xl.", context: self) do
        <<~RUBY
          div(class: "flex flex-wrap items-center gap-2 justify-center") do
            Button(variant: :outline, size: :xs) { "Extra Small" }
            Button(variant: :outline, size: :sm) { "Small" }
            Button(variant: :outline) { "Default" }
            Button(variant: :outline, size: :lg) { "Large" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Icon", description: "icon: true makes a square button of the given size. Give it an aria-label.", context: self) do
        <<~RUBY
          div(class: "flex flex-wrap items-center gap-2 justify-center") do
            [:xs, :sm, :md, :lg].each do |size|
              Button(variant: :outline, size: size, icon: true, aria: {label: "Next"}) do
                svg(xmlns: "http://www.w3.org/2000/svg", width: "24", height: "24", viewbox: "0 0 24 24", fill: "none",
                  stroke: "currentColor", stroke_width: "2", stroke_linecap: "round", stroke_linejoin: "round",
                  aria_hidden: "true") do |s|
                  s.path(d: "m9 18 6-6-6-6")
                end
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "With Icon", description: "Mark the icon with data-icon=\"inline-start\" or \"inline-end\" so the button tightens the padding on that side. Icons are sized to 16px unless they carry a size-* class.", context: self) do
        <<~RUBY
          div(class: "flex flex-wrap items-center gap-2 justify-center") do
            Button(variant: :outline) do
              svg(xmlns: "http://www.w3.org/2000/svg", width: "24", height: "24", viewbox: "0 0 24 24", fill: "none",
                stroke: "currentColor", stroke_width: "2", stroke_linecap: "round", stroke_linejoin: "round",
                aria_hidden: "true", data: {icon: "inline-start"}) do |s|
                s.path(d: "M6 3v12")
                s.circle(cx: "18", cy: "6", r: "3")
                s.circle(cx: "6", cy: "18", r: "3")
                s.path(d: "M18 9a9 9 0 0 1-9 9")
              end
              plain "New Branch"
            end
            Button do
              plain "Send"
              svg(xmlns: "http://www.w3.org/2000/svg", width: "24", height: "24", viewbox: "0 0 24 24", fill: "none",
                stroke: "currentColor", stroke_width: "2", stroke_linecap: "round", stroke_linejoin: "round",
                aria_hidden: "true", data: {icon: "inline-end"}) do |s|
                s.path(d: "m22 2-7 20-4-9-9-4Z")
                s.path(d: "M22 2 11 13")
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Loading", context: self) do
        <<~RUBY
          Button(variant: :outline, disabled: true) do
            svg(xmlns: "http://www.w3.org/2000/svg", width: "24", height: "24", viewbox: "0 0 24 24", fill: "none",
              stroke: "currentColor", stroke_width: "2", stroke_linecap: "round", stroke_linejoin: "round",
              aria_hidden: "true", class: "animate-spin", data: {icon: "inline-start"}) do |s|
              s.path(d: "M21 12a9 9 0 1 1-6.219-8.56")
            end
            plain "Please wait"
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "As Link", description: "Pass href: to render an <a> that looks like a button.", context: self) do
        <<~RUBY
          Button(href: "#") { "Login" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Disabled", context: self) do
        <<~RUBY
          Button(disabled: true) { "Disabled" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Focusable When Disabled", description: "focusable_when_disabled: true keeps a disabled button in the tab order (aria-disabled instead of disabled), for example so a tooltip can explain why. Clicks and keyboard activation are blocked.", context: self) do
        <<~RUBY
          Button(disabled: true, focusable_when_disabled: true) { "Focusable" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Invalid", description: "aria-invalid paints the border and focus ring in the destructive color.", context: self) do
        <<~RUBY
          Button(variant: :outline, aria: {invalid: "true"}) { "Pick a date" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Submit", context: self) do
        <<~RUBY
          Button(type: :submit) { "Submit application" }
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
