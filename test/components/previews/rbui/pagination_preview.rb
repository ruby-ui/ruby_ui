# frozen_string_literal: true

module Rbui
  class PaginationPreview < Lookbook::Preview
    # Default Pagination
    # ---------------
    def default
      render(TestView.new) do
        Pagination do
          PaginationContent do
            PaginationItem(href: "#") do
              plain(helpers.lucide_icon("chevrons-left", class: "w-4 h-4"))
              plain "First"
            end

            PaginationItem(href: "#") do
              plain(helpers.lucide_icon("chevron-left", class: "w-4 h-4"))
              plain "Prev"
            end

            PaginationEllipsis()

            PaginationItem(href: "#") { "4" }
            PaginationItem(href: "#", active: true) { "5" }
            PaginationItem(href: "#") { "6" }

            PaginationEllipsis()

            PaginationItem(href: "#") do
              plain "Next"
              plain(helpers.lucide_icon("chevron-right", class: "w-4 h-4"))
            end

            PaginationItem(href: "#") do
              plain "Last"
              plain(helpers.lucide_icon("chevrons-right", class: "w-4 h-4"))
            end
          end
        end
      end
    end
  end
end
