# frozen_string_literal: true

class Docs::PaginationView < ApplicationView
  def view_template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Pagination", description: "Pagination with page navigation, next and previous links.")

      render PhlexUI::Typography::H2.new { "Usage" }

      render Docs::VisualCodeExample.new(title: "Example", description: "This is the default appearance of a Pagination", context: self) do
        <<~RUBY
          render PhlexUI::Pagination.new do
            render PhlexUI::Pagination::Content.new do
              render PhlexUI::Pagination::Item.new(href: "#") do
                chevrons_left_icon
                plain "First"
              end
              render PhlexUI::Pagination::Item.new(href: "#") do
                chevron_left_icon
                plain "Prev"
              end

              render PhlexUI::Pagination::Ellipsis.new

              render PhlexUI::Pagination::Item.new(href: "#") { "4" }
              render PhlexUI::Pagination::Item.new(href: "#", active: true) { "5" }
              render PhlexUI::Pagination::Item.new(href: "#") { "6" }

              render PhlexUI::Pagination::Ellipsis.new

              render PhlexUI::Pagination::Item.new(href: "#") do
                plain "Next"
                chevron_right_icon
              end
              render PhlexUI::Pagination::Item.new(href: "#") do
                plain "Last"
                chevrons_right_icon
              end
            end
          end
        RUBY
      end

      render Docs::ComponentsTable.new(components)
    end
  end

  private

  def components
    [
      Docs::ComponentStruct.new(name: "PhlexUI::Pagination", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/pagination.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::Pagination::Content", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/pagination/content.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::Pagination::Ellipsis", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/pagination/ellipsis.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "PhlexUI::Pagination::Item", source: "https://github.com/PhlexUI/phlex_ui/blob/main/lib/phlex_ui/pagination/item.rb", built_using: :phlex)
    ]
  end

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
