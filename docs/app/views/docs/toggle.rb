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
