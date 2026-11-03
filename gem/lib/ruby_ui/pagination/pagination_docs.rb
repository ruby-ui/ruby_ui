# frozen_string_literal: true

class Views::Docs::Pagination < Views::Base
  def view_template
    component = "Pagination"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Pagination", description: "Pagination with page navigation, next and previous links.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Example", context: self) do
        <<~RUBY
          Pagination do
            PaginationContent do
              PaginationPrevious(href: "#")
              PaginationItem(href: "#") { "1" }
              PaginationItem(href: "#", active: true) { "2" }
              PaginationItem(href: "#") { "3" }
              PaginationEllipsis()
              PaginationNext(href: "#")
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Simple", description: "Page numbers only.", context: self) do
        <<~RUBY
          Pagination do
            PaginationContent do
              PaginationItem(href: "#") { "1" }
              PaginationItem(href: "#", active: true) { "2" }
              PaginationItem(href: "#") { "3" }
              PaginationItem(href: "#") { "4" }
              PaginationItem(href: "#") { "5" }
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Custom labels", description: "Previous and Next take text:; translate the aria-label with it, using label! to replace the default. Below the sm breakpoint only the chevron shows.", context: self) do
        <<~RUBY
          Pagination do
            PaginationContent do
              PaginationPrevious(href: "#", text: "Anterior", aria: {label!: "Página anterior"})
              PaginationItem(href: "#", size: :default) { "Página 2 de 10" }
              PaginationNext(href: "#", text: "Próxima", aria: {label!: "Próxima página"})
            end
          end
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
