# frozen_string_literal: true

class Views::Docs::Breadcrumb < Views::Base
  def view_template
    component = "Breadcrumb"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Breadcrumb", description: "Indicates the user's current location within a navigational hierarchy.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Example", context: self) do
        <<~RUBY
          Breadcrumb do
            BreadcrumbList do
              BreadcrumbItem do
                BreadcrumbLink(href: "/") { "Home" }
              end
              BreadcrumbSeparator()
              BreadcrumbItem do
                BreadcrumbLink(href: "/docs/accordion") { "Components" }
              end
              BreadcrumbSeparator()
              BreadcrumbItem do
                BreadcrumbPage { "Breadcrumb" }
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "With custom separator", context: self) do
        <<~RUBY
          Breadcrumb do
            BreadcrumbList do
              BreadcrumbItem do
                BreadcrumbLink(href: "/") { "Home" }
              end
              BreadcrumbSeparator { slash_icon }
              BreadcrumbItem do
                BreadcrumbLink(href: "/docs/accordion") { "Components" }
              end
              BreadcrumbSeparator { slash_icon }
              BreadcrumbItem do
                BreadcrumbPage { "Breadcrumb" }
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Collapsed", context: self) do
        <<~RUBY
          Breadcrumb do
            BreadcrumbList do
              BreadcrumbItem do
                BreadcrumbLink(href: "/") { "Home" }
              end
              BreadcrumbSeparator()
              BreadcrumbItem do
                BreadcrumbEllipsis()
              end
              BreadcrumbSeparator()
              BreadcrumbItem do
                BreadcrumbLink(href: "/docs/accordion") { "Components" }
              end
              BreadcrumbSeparator()
              BreadcrumbItem do
                BreadcrumbPage { "Breadcrumb" }
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "With Link component", context: self) do
        <<~RUBY
          Breadcrumb do
            BreadcrumbList do
              BreadcrumbItem do
                BreadcrumbLink(href: "/") { "Home" }
              end
              BreadcrumbSeparator()
              BreadcrumbItem do
                Link(href: "/docs/accordion", class: "px-0") { "Components" }
              end
              BreadcrumbSeparator()
              BreadcrumbItem do
                BreadcrumbPage { "Breadcrumb" }
              end
            end
          end
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end

  private

  def slash_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      class: "w-4 h-4",
      viewbox: "0 0 24 24",
      fill: "none",
      stroke: "currentColor",
      stroke_width: "2",
      stroke_linecap: "round",
      stroke_linejoin: "round"
    ) { |s| s.path(d: "M22 2 2 22") }
  end
end
