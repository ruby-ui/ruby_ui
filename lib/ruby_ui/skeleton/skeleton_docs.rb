# frozen_string_literal: true

class Views::Docs::Skeleton < Views::Base
  def view_template
    component = "Skeleton"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Skeleton", description: "Use to show a placeholder while content is loading.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Example", context: self) do
        <<~RUBY
          div(class: "flex items-center space-x-4") do
            Skeleton(class: "h-12 w-12 rounded-full")
            div(class: "space-y-2") do
              Skeleton(class: "h-4 w-[250px]")
              Skeleton(class: "h-4 w-[200px]")
            end
          end
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
