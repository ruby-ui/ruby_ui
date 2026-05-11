# frozen_string_literal: true

class Views::Docs::ToggleGroup < Views::Base
  def view_template
    component = "ToggleGroup"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(
        title: "Toggle Group",
        description: "A set of two-state buttons that can be toggled on or off, with single or multiple selection. Mirrors shadcn/ui ToggleGroup."
      )

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Default", context: self) do
        <<~RUBY
          ToggleGroup(type: :single, name: "letter", value: "a") do |g|
            g.ToggleGroupItem(value: "a") { "A" }
            g.ToggleGroupItem(value: "b") { "B" }
            g.ToggleGroupItem(value: "c") { "C" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Outline", context: self) do
        <<~RUBY
          ToggleGroup(type: :multiple, name: "fmt", variant: :outline, value: %w[bold]) do |g|
            g.ToggleGroupItem(value: "bold") { "B" }
            g.ToggleGroupItem(value: "italic") { "I" }
            g.ToggleGroupItem(value: "underline") { "U" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Single", context: self) do
        <<~RUBY
          ToggleGroup(type: :single, name: "view", value: "all", variant: :outline) do |g|
            g.ToggleGroupItem(value: "all") { "All" }
            g.ToggleGroupItem(value: "missed") { "Missed" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Size", context: self) do
        <<~RUBY
          div(class: "flex flex-col gap-4") do
            ToggleGroup(type: :multiple, name: "fmt_sm", variant: :outline, size: :sm) do |g|
              g.ToggleGroupItem(value: "bold") { "B" }
              g.ToggleGroupItem(value: "italic") { "I" }
              g.ToggleGroupItem(value: "underline") { "U" }
            end
            ToggleGroup(type: :multiple, name: "fmt_default", variant: :outline) do |g|
              g.ToggleGroupItem(value: "bold") { "B" }
              g.ToggleGroupItem(value: "italic") { "I" }
              g.ToggleGroupItem(value: "underline") { "U" }
            end
            ToggleGroup(type: :multiple, name: "fmt_lg", variant: :outline, size: :lg) do |g|
              g.ToggleGroupItem(value: "bold") { "B" }
              g.ToggleGroupItem(value: "italic") { "I" }
              g.ToggleGroupItem(value: "underline") { "U" }
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Spacing", context: self) do
        <<~RUBY
          ToggleGroup(type: :single, name: "align", value: "top", variant: :outline, spacing: 2) do |g|
            g.ToggleGroupItem(value: "top") { "Top" }
            g.ToggleGroupItem(value: "bottom") { "Bottom" }
            g.ToggleGroupItem(value: "left") { "Left" }
            g.ToggleGroupItem(value: "right") { "Right" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Vertical", context: self) do
        <<~RUBY
          ToggleGroup(type: :multiple, name: "fmt_v", variant: :outline, orientation: :vertical, value: %w[bold]) do |g|
            g.ToggleGroupItem(value: "bold") { "B" }
            g.ToggleGroupItem(value: "italic") { "I" }
            g.ToggleGroupItem(value: "underline") { "U" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Disabled", context: self) do
        <<~RUBY
          ToggleGroup(type: :multiple, name: "fmt_d", variant: :outline, disabled: true) do |g|
            g.ToggleGroupItem(value: "bold") { "B" }
            g.ToggleGroupItem(value: "italic") { "I" }
            g.ToggleGroupItem(value: "underline") { "U" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Custom", context: self) do
        <<~RUBY
          ToggleGroup(type: :single, name: "weight", value: "normal", variant: :outline, spacing: 2) do |g|
            g.ToggleGroupItem(value: "light", size: :lg, class: "h-auto flex-col gap-1 py-2") do
              span(class: "text-base font-light") { "Aa" }
              span(class: "text-xs text-muted-foreground") { "Light" }
            end
            g.ToggleGroupItem(value: "normal", size: :lg, class: "h-auto flex-col gap-1 py-2") do
              span(class: "text-base font-normal") { "Aa" }
              span(class: "text-xs text-muted-foreground") { "Normal" }
            end
            g.ToggleGroupItem(value: "medium", size: :lg, class: "h-auto flex-col gap-1 py-2") do
              span(class: "text-base font-medium") { "Aa" }
              span(class: "text-xs text-muted-foreground") { "Medium" }
            end
            g.ToggleGroupItem(value: "bold", size: :lg, class: "h-auto flex-col gap-1 py-2") do
              span(class: "text-base font-bold") { "Aa" }
              span(class: "text-xs text-muted-foreground") { "Bold" }
            end
          end
        RUBY
      end

      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
