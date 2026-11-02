# frozen_string_literal: true

module ShadcnAuditFixtures
  # RubyUI side of audit/fixtures/breadcrumb (strings in content.yml).
  class Breadcrumb < Phlex::HTML
    include RubyUI

    def view_template
      Breadcrumb do
        BreadcrumbList do
          BreadcrumbItem do
            BreadcrumbLink(href: "#", data: {audit_trigger: true}) { "Home" }
          end
          BreadcrumbSeparator()
          BreadcrumbItem do
            BreadcrumbEllipsis()
          end
          BreadcrumbSeparator()
          BreadcrumbItem do
            BreadcrumbLink(href: "#") { "Components" }
          end
          BreadcrumbSeparator()
          BreadcrumbItem do
            BreadcrumbPage { "Breadcrumb" }
          end
        end
      end
    end
  end
end
