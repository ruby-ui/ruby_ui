# frozen_string_literal: true

class Views::Docs::Separator < Views::Base
  def view_template
    component = "Separator"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Separator", description: "Visually or semantically separates content.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Example", context: self) do
        <<~RUBY
          div do
            div(class: "space-y-1") do
              h4(class: "text-sm font-medium leading-none") { "RubyUI" }
              p(class: "text-sm text-muted-foreground") { "An open-source UI component library." }
            end
            Separator(class: "my-4")
            div(class: "flex h-5 items-center space-x-4 text-sm") do
              div { "Blog" }
              Separator(as: :hr, orientation: :vertical)
              div { "Docs" }
              Separator(orientation: :vertical)
              div { "Source" }
            end
          end
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
