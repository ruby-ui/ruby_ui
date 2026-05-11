# frozen_string_literal: true

class Views::Docs::ToggleGroup < Views::Base
  def view_template
    component = "ToggleGroup"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(
        title: "Toggle Group",
        description: "A set of two-state buttons that can be toggled on or off, with single or multiple selection."
      )

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Single selection", context: self) do
        <<~RUBY
          ToggleGroup(type: :single, name: "align", value: "left") do |g|
            g.ToggleGroupItem(value: "left") { "Left" }
            g.ToggleGroupItem(value: "center") { "Center" }
            g.ToggleGroupItem(value: "right") { "Right" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Multiple selection", context: self) do
        <<~RUBY
          ToggleGroup(type: :multiple, name: "fmt", value: %w[bold]) do |g|
            g.ToggleGroupItem(value: "bold") { "B" }
            g.ToggleGroupItem(value: "italic") { "I" }
            g.ToggleGroupItem(value: "underline") { "U" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Outline variant", context: self) do
        <<~RUBY
          ToggleGroup(type: :single, name: "align", variant: :outline) do |g|
            g.ToggleGroupItem(value: "left") { "Left" }
            g.ToggleGroupItem(value: "center") { "Center" }
            g.ToggleGroupItem(value: "right") { "Right" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Sizes", context: self) do
        <<~RUBY
          ToggleGroup(type: :single, name: "size", size: :sm) do |g|
            g.ToggleGroupItem(value: "a") { "A" }
            g.ToggleGroupItem(value: "b") { "B" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Disabled", context: self) do
        <<~RUBY
          ToggleGroup(type: :multiple, name: "fmt", disabled: true) do |g|
            g.ToggleGroupItem(value: "bold") { "B" }
            g.ToggleGroupItem(value: "italic") { "I" }
          end
        RUBY
      end

      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
