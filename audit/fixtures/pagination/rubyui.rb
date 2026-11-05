# frozen_string_literal: true

module ShadcnAuditFixtures
  # RubyUI side of audit/fixtures/pagination (strings in content.yml).
  class Pagination < Phlex::HTML
    include RubyUI

    def view_template
      Pagination do
        PaginationContent do
          PaginationPrevious(href: "#")
          PaginationItem(href: "#", data: {audit_trigger: true}) { "1" }
          PaginationItem(href: "#", active: true) { "2" }
          PaginationItem(href: "#") { "3" }
          PaginationEllipsis()
          PaginationNext(href: "#")
        end
      end
    end
  end
end
