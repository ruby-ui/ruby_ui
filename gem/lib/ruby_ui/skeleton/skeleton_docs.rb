# frozen_string_literal: true

class Views::Docs::Skeleton < Views::Base
  def view_template
    component = "Skeleton"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Skeleton", description: "Use to show a placeholder while content is loading.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Avatar", context: self) do
        <<~RUBY
          div(class: "flex w-full items-center gap-4") do
            Skeleton(class: "size-10 shrink-0 rounded-full")
            div(class: "grid gap-2") do
              Skeleton(class: "h-4 w-[150px]")
              Skeleton(class: "h-4 w-[100px]")
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Card", context: self) do
        <<~RUBY
          Card(class: "w-full") do
            CardHeader do
              Skeleton(class: "h-4 w-2/3")
              Skeleton(class: "h-4 w-1/2")
            end
            CardContent do
              Skeleton(class: "aspect-square w-full")
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Text", context: self) do
        <<~RUBY
          div(class: "flex w-full flex-col gap-2") do
            Skeleton(class: "h-4 w-full")
            Skeleton(class: "h-4 w-full")
            Skeleton(class: "h-4 w-3/4")
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Form", context: self) do
        <<~RUBY
          div(class: "flex w-full flex-col gap-7") do
            div(class: "flex flex-col gap-3") do
              Skeleton(class: "h-4 w-20")
              Skeleton(class: "h-10 w-full")
            end
            div(class: "flex flex-col gap-3") do
              Skeleton(class: "h-4 w-24")
              Skeleton(class: "h-10 w-full")
            end
            Skeleton(class: "h-9 w-24")
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Table", context: self) do
        <<~RUBY
          div(class: "flex w-full flex-col gap-2") do
            3.times do
              div(class: "flex gap-4") do
                Skeleton(class: "h-4 flex-1")
                Skeleton(class: "h-4 w-24")
                Skeleton(class: "h-4 w-20")
              end
            end
          end
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
