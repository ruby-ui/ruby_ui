# frozen_string_literal: true

require "test_helper"

class RubyUI::BreadcrumbTest < ComponentTest
  def test_render_with_all_items
    output = phlex do
      RubyUI.Breadcrumb do
        RubyUI.BreadcrumbList do
          RubyUI.BreadcrumbItem do
            RubyUI.BreadcrumbLink(href: "#") { "Home" }
          end
          RubyUI.BreadcrumbSeparator()
          RubyUI.BreadcrumbItem do
            RubyUI.BreadcrumbLink(href: "/docs/accordion") { "Components" }
          end
          RubyUI.BreadcrumbSeparator()
          RubyUI.BreadcrumbItem do
            RubyUI.BreadcrumbPage { "Breadcrumb" }
          end
        end
      end
    end

    assert_match(/Components/, output)
  end
end
