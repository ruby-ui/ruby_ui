# frozen_string_literal: true

require "test_helper"

class RubyUI::BreadcrumbTest < ComponentTest
  def render_breadcrumb
    phlex do
      RubyUI.Breadcrumb do
        RubyUI.BreadcrumbList do
          RubyUI.BreadcrumbItem do
            RubyUI.BreadcrumbLink(href: "#") { "Home" }
          end
          RubyUI.BreadcrumbSeparator()
          RubyUI.BreadcrumbItem do
            RubyUI.BreadcrumbEllipsis()
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
  end

  def test_render_with_all_items
    assert_match(/Components/, render_breadcrumb)
  end

  def test_data_slot_on_every_part
    output = render_breadcrumb

    %w[breadcrumb breadcrumb-list breadcrumb-item breadcrumb-link breadcrumb-page breadcrumb-separator breadcrumb-ellipsis].each do |slot|
      assert_match(/data-slot="#{slot}"/, output)
    end
  end

  # Phlex renders `true` as a bare attribute (aria-hidden=""), which ARIA
  # treats as undefined, so the values must be the string "true".
  def test_hidden_parts_use_explicit_true
    output = render_breadcrumb

    assert_match(/<li aria-hidden="true" data-slot="breadcrumb-separator"/, output)
    assert_match(/<span aria-hidden="true" data-slot="breadcrumb-ellipsis"/, output)
    assert_match(/aria-disabled="true"/, output)
    refute_match(/aria-(hidden|disabled)(?!=)/, output)
  end

  def test_separator_has_no_role
    output = phlex { RubyUI.BreadcrumbSeparator() }

    refute_match(/role=/, output)
  end

  def test_ellipsis_matches_vega_size
    output = phlex { RubyUI.BreadcrumbEllipsis() }

    assert_match(/size-5/, output)
    refute_match(/h-9|w-9/, output)
  end
end
