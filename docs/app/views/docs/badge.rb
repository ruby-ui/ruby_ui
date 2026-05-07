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

      render Docs::VisualCodeExample.new(title: "Primary", context: self) do
        <<~RUBY
          Badge(variant: :primary) { 'Primary' }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Outline", context: self) do
        <<~RUBY
          Badge(variant: :outline) { 'Outline' }
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Variants", context: self) do
        <<~RUBY
          div(class: 'flex flex-wrap gap-2 justify-center') do
            Badge(variant: :destructive) { 'Destructive' }
            Badge(variant: :warning) { 'Warning' }
            Badge(variant: :success) { 'Success' }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Other Colors", context: self) do
        <<~RUBY
          div(class: 'flex flex-wrap gap-2 justify-center') do
            Badge(variant: :red) { 'Red' }
            Badge(variant: :orange) { 'Orange' }
            Badge(variant: :amber) { 'Amber' }
            Badge(variant: :yellow) { 'Yellow' }
            Badge(variant: :lime) { 'Lime' }
            Badge(variant: :green) { 'Green' }
            Badge(variant: :emerald) { 'Emerald' }
            Badge(variant: :teal) { 'Teal' }
            Badge(variant: :cyan) { 'Cyan' }
            Badge(variant: :sky) { 'Sky' }
            Badge(variant: :blue) { 'Blue' }
            Badge(variant: :indigo) { 'Indigo' }
            Badge(variant: :violet) { 'Violet' }
            Badge(variant: :purple) { 'Purple' }
            Badge(variant: :fuchsia) { 'Fuchsia' }
            Badge(variant: :pink) { 'Pink' }
            Badge(variant: :rose) { 'Rose' }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Sizes", context: self) do
        <<~RUBY
          div(class: 'flex flex-wrap gap-2 justify-center items-center') do
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
