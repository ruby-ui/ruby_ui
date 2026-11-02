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

    {
      "breadcrumb" => "nav", "breadcrumb-list" => "ol", "breadcrumb-item" => "li",
      "breadcrumb-link" => "a", "breadcrumb-page" => "span",
      "breadcrumb-separator" => "li", "breadcrumb-ellipsis" => "span"
    }.each do |slot, tag|
      assert opening_tag(output, slot).start_with?("<#{tag} "), "#{slot} should be a <#{tag}>"
    end
  end

  # Phlex renders `true` as a bare attribute (aria-hidden=""), which ARIA
  # treats as undefined, so the values must be the string "true".
  def test_hidden_parts_use_explicit_true
    output = render_breadcrumb

    assert_includes opening_tag(output, "breadcrumb-separator"), 'aria-hidden="true"'
    assert_includes opening_tag(output, "breadcrumb-ellipsis"), 'aria-hidden="true"'
    assert_includes opening_tag(output, "breadcrumb-page"), 'aria-disabled="true"'
    refute_match(/aria-(hidden|disabled)(?!=)/, output)
  end

  def test_separator_has_no_role
    refute_match(/role=/, opening_tag(phlex { RubyUI.BreadcrumbSeparator() }, "breadcrumb-separator"))
  end

  # The svgs carry no size of their own: the parent sizes them, as in vega.
  def test_sizes_match_vega
    separator = opening_tag(phlex { RubyUI.BreadcrumbSeparator() }, "breadcrumb-separator")
    ellipsis = opening_tag(phlex { RubyUI.BreadcrumbEllipsis() }, "breadcrumb-ellipsis")

    assert_includes separator, "[&>svg]:size-3.5"
    assert_includes ellipsis, "size-5"
    assert_includes ellipsis, "[&>svg]:size-4"
    refute_match(/\bh-9\b|\bw-9\b/, ellipsis)
  end

  private

  # The opening tag of the part with this data-slot, whatever the attribute
  # order (quoted values may contain ">", e.g. [&>svg]:size-4).
  def opening_tag(output, slot)
    output[/<[a-z]+\b(?:[^>"]|"[^"]*")*data-slot="#{slot}"(?:[^>"]|"[^"]*")*>/] || flunk("no #{slot} in #{output}")
  end
end
