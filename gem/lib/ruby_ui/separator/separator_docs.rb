# frozen_string_literal: true

class Views::Docs::Separator < Views::Base
  def view_template
    component = "Separator"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Separator", description: "Visually or semantically separates content.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Horizontal", context: self) do
        <<~RUBY
          div(class: "flex flex-col gap-4 text-sm") do
            div(class: "flex flex-col gap-1") do
              div(class: "leading-none font-medium") { "RubyUI" }
              div(class: "text-muted-foreground") { "An open-source UI component library." }
            end
            Separator()
            div { "Beautifully designed Phlex components that you can customize, extend, and build on." }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Vertical", description: "A vertical separator stretches to the height of its flex row.", context: self) do
        <<~RUBY
          div(class: "flex h-5 items-center gap-4 text-sm") do
            div { "Blog" }
            Separator(orientation: :vertical)
            div { "Docs" }
            Separator(orientation: :vertical)
            div { "Source" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Vertical Menu", description: "No fixed height needed: the separator fills the row.", context: self) do
        <<~RUBY
          div(class: "flex items-center gap-2 text-sm md:gap-4") do
            div(class: "flex flex-col gap-1") do
              span(class: "font-medium") { "Settings" }
              span(class: "text-xs text-muted-foreground") { "Manage preferences" }
            end
            Separator(orientation: :vertical)
            div(class: "flex flex-col gap-1") do
              span(class: "font-medium") { "Account" }
              span(class: "text-xs text-muted-foreground") { "Profile & security" }
            end
            Separator(orientation: :vertical)
            div(class: "flex flex-col gap-1") do
              span(class: "font-medium") { "Help" }
              span(class: "text-xs text-muted-foreground") { "Support & docs" }
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "In List", context: self) do
        <<~RUBY
          div(class: "flex flex-col gap-2 text-sm") do
            dl(class: "flex items-center justify-between") do
              dt { "Item 1" }
              dd(class: "text-muted-foreground") { "Value 1" }
            end
            Separator()
            dl(class: "flex items-center justify-between") do
              dt { "Item 2" }
              dd(class: "text-muted-foreground") { "Value 2" }
            end
            Separator()
            dl(class: "flex items-center justify-between") do
              dt { "Item 3" }
              dd(class: "text-muted-foreground") { "Value 3" }
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Decorative", description: "Separators are announced by screen readers (role=\"separator\" with aria-orientation). Pass decorative: true for a purely visual line (role=\"none\").", context: self) do
        <<~RUBY
          div(class: "flex h-5 items-center gap-4 text-sm") do
            div { "Profile" }
            Separator(orientation: :vertical, decorative: true)
            div { "Settings" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "As <hr>", description: "as: :hr renders the native separator element. Its separator role is implicit, so no role attribute is added.", context: self) do
        <<~RUBY
          div(class: "flex flex-col gap-4 text-sm") do
            div { "Section one" }
            Separator(as: :hr)
            div { "Section two" }
          end
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
