# frozen_string_literal: true

class Views::Docs::Pagination < Views::Base
  def view_template
    component = "Pagination"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Pagination", description: "Pagination with page navigation, next and previous links.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Example", description: "This is the default appearance of a Pagination", context: self) do
        <<~RUBY
          Pagination do
            PaginationContent do
              PaginationItem(href: "#") do
                chevrons_left_icon
                plain "First"
              end
              PaginationItem(href: "#") do
                chevron_left_icon
                plain "Prev"
              end

              PaginationEllipsis

              PaginationItem(href: "#") { "4" }
              PaginationItem(href: "#", active: true) { "5" }
              PaginationItem(href: "#") { "6" }

              PaginationEllipsis

              PaginationItem(href: "#") do
                plain "Next"
                chevron_right_icon
              end
              PaginationItem(href: "#") do
                plain "Last"
                chevrons_right_icon
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

  def chevrons_left_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      width: "24",
      height: "24",
      viewbox: "0 0 24 24",
      stroke_width: "1.5",
      stroke: "currentColor",
      fill: "none",
      stroke_linecap: "round",
      stroke_linejoin: "round",
      class: "h-4 w-4"
    ) do |s|
      s.path(stroke: "none", d: "M0 0h24v24H0z", fill: "none")
      s.path(d: "M11 7l-5 5l5 5")
      s.path(d: "M17 7l-5 5l5 5")
    end
  end

  def chevron_left_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      width: "24",
      height: "24",
      viewbox: "0 0 24 24",
      stroke_width: "1.5",
      stroke: "currentColor",
      fill: "none",
      stroke_linecap: "round",
      stroke_linejoin: "round",
      class: "h-4 w-4"
    ) do |s|
      s.path(stroke: "none", d: "M0 0h24v24H0z", fill: "none")
      s.path(d: "M15 6l-6 6l6 6")
    end
  end

  def chevrons_right_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      width: "24",
      height: "24",
      viewbox: "0 0 24 24",
      stroke_width: "1.5",
      stroke: "currentColor",
      fill: "none",
      stroke_linecap: "round",
      stroke_linejoin: "round",
      class: "h-4 w-4"
    ) do |s|
      s.path(stroke: "none", d: "M0 0h24v24H0z", fill: "none")
      s.path(d: "M7 7l5 5l-5 5")
      s.path(d: "M13 7l5 5l-5 5")
    end
  end

  def chevron_right_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      width: "24",
      height: "24",
      viewbox: "0 0 24 24",
      stroke_width: "1.5",
      stroke: "currentColor",
      fill: "none",
      stroke_linecap: "round",
      stroke_linejoin: "round",
      class: "h-4 w-4"
    ) do |s|
      s.path(stroke: "none", d: "M0 0h24v24H0z", fill: "none")
      s.path(d: "M9 6l6 6l-6 6")
    end
  end
end
