# frozen_string_literal: true

class Errors::InternalServerErrorView < ApplicationView
  def view_template
    render PhlexUI::Card.new(class: "p-8 space-y-6 flex flex-col items-center") do
      div(class: "space-y-2") do
        render PhlexUI::Badge.new(variant: :destructive, class: "font-mono") { "STATUS: 500" }
        render PhlexUI::Typography::H1.new(class: "!leading-tight") { "Oops! Something went wrong" }
        render PhlexUI::Typography::P.new(class: "text-muted-foreground") { "Something unexpected happened. We're looking into it." }
      end

      render PhlexUI::Link.new(href: helpers.root_path, variant: :primary, class: "w-full") do
        house_icon
        plain "Go to home"
      end
    end
  end

  private

  def back_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      fill: "none",
      viewbox: "0 0 24 24",
      stroke_width: "1.5",
      stroke: "currentColor",
      class: "w-4 h-4 mr-2"
    ) do |s|
      s.path(
        stroke_linecap: "round",
        stroke_linejoin: "round",
        d: "M10.5 19.5L3 12m0 0l7.5-7.5M3 12h18"
      )
    end
  end

  def house_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      fill: "none",
      viewbox: "0 0 24 24",
      stroke_width: "1.5",
      stroke: "currentColor",
      class: "w-4 h-4 mr-2"
    ) do |s|
      s.path(
        stroke_linecap: "round",
        stroke_linejoin: "round",
        d:
          "M2.25 12l8.954-8.955c.44-.439 1.152-.439 1.591 0L21.75 12M4.5 9.75v10.125c0 .621.504 1.125 1.125 1.125H9.75v-4.875c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125V21h4.125c.621 0 1.125-.504 1.125-1.125V9.75M8.25 21h8.25"
      )
    end
  end
end
