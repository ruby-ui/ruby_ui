# frozen_string_literal: true

module RubyUI
  # Link to the previous page: chevron plus text, which collapses to the icon
  # below the sm breakpoint. text: changes the label.
  class PaginationPrevious < PaginationItem
    def initialize(href: "#", text: "Previous", **attrs)
      @text = text
      super(href: href, size: :default, **attrs)
    end

    def view_template
      li(data: {slot: "pagination-item"}) do
        a(href: @href, **attrs) do
          svg(xmlns: "http://www.w3.org/2000/svg", width: "24", height: "24", viewbox: "0 0 24 24", fill: "none",
            stroke: "currentColor", stroke_width: "2", stroke_linecap: "round", stroke_linejoin: "round",
            aria_hidden: "true", data: {icon: "inline-start"}) do |s|
            s.path(d: "m15 18-6-6 6-6")
          end
          span(class: "hidden sm:block") { @text }
        end
      end
    end

    private

    def default_attrs
      mix(super, {aria: {label: "Go to previous page"}, class: "pl-2!"})
    end
  end
end
