# frozen_string_literal: true

class Views::Docs::Button < Views::Base
  def view_template
    component = "Button"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Button", description: "Displays a button or a component that looks like a button.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Example", context: self) do
        <<~RUBY
          Button { "Button" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Primary", context: self) do
        <<~RUBY
          Button(variant: :primary) { "Primary" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Secondary", context: self) do
        <<~RUBY
          Button(variant: :secondary) { "Secondary" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Destructive", context: self) do
        <<~RUBY
          Button(variant: :destructive) { "Destructive" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Outline", context: self) do
        <<~RUBY
          Button(variant: :outline) { "Outline" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Ghost", context: self) do
        <<~RUBY
          Button(variant: :ghost) { "Ghost" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Link", context: self) do
        <<~RUBY
          Button(variant: :link) { "Link" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Disabled", context: self) do
        <<~RUBY
          Button(disabled: true) { "Disabled" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Aria Disabled", context: self) do
        <<~RUBY
          Button(aria: {disabled: "true"}) { "Aria Disabled" }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Icon", context: self) do
        <<~RUBY
          Button(variant: :outline, icon: true) do
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
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "With Icon", context: self) do
        <<~RUBY
          Button(variant: :primary) do
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
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "With Icon", context: self) do
        <<~RUBY
          Button(variant: :primary, disabled: true) do
            svg(
              xmlns: "http://www.w3.org/2000/svg",
              viewbox: "0 0 20 20",
              fill: "currentColor",
              class: "w-4 h-4 mr-2 animate-spin"
            ) do |s|
              s.path(
                fill_rule: "evenodd",
                d:
                  "M15.312 11.424a5.5 5.5 0 01-9.201 2.466l-.312-.311h2.433a.75.75 0 000-1.5H3.989a.75.75 0 00-.75.75v4.242a.75.75 0 001.5 0v-2.43l.31.31a7 7 0 0011.712-3.138.75.75 0 00-1.449-.39zm1.23-3.723a.75.75 0 00.219-.53V2.929a.75.75 0 00-1.5 0V5.36l-.31-.31A7 7 0 003.239 8.188a.75.75 0 101.448.389A5.5 5.5 0 0113.89 6.11l.311.31h-2.432a.75.75 0 000 1.5h4.243a.75.75 0 00.53-.219z",
                clip_rule: "evenodd"
              )
            end
            span { "Please wait" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Submit", context: self) do
        <<~RUBY
          Button(variant: :primary, type: :submit) do
            span { "Submit application" }
          end
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
