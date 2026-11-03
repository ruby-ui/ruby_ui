# frozen_string_literal: true

module RubyUI
  class BreadcrumbSeparator < Base
    def view_template(&block)
      li(**attrs) do
        if block
          block.call
        else
          icon
        end
      end
    end

    private

    def icon
      svg(
        xmlns: "http://www.w3.org/2000/svg",
        viewbox: "0 0 24 24",
        fill: "none",
        stroke: "currentColor",
        stroke_width: "2",
        stroke_linecap: "round",
        stroke_linejoin: "round",
        aria_hidden: "true"
      ) { |s| s.path(d: "m9 18 6-6-6-6") }
    end

    # No role="presentation": an li in a list may only be a listitem
    # (https://www.w3.org/TR/html-aria/#el-li). aria-hidden="true" alone
    # keeps the separator out of the accessibility tree.
    def default_attrs
      {
        aria: {hidden: "true"},
        data: {slot: "breadcrumb-separator"},
        class: "[&>svg]:size-3.5"
      }
    end
  end
end
