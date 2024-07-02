# frozen_string_literal: true

class Shared::MobileMenu < ApplicationComponent
  def initialize(**attributes)
    @attributes = attributes
  end

  def view_template
    Sheet(class: @attributes[:class]) do
      SheetTrigger do
        Button(variant: :ghost, icon: true) do
          menu_icon
        end
      end
      SheetContent(class: "w-[300px]", side: :left) do
        div(class: "flex flex-col h-full") do
          SheetHeader do
            div(class: "pl-2") do
              render Shared::Logo.new
            end
          end
          div(class: "flex-grow overflow-y-scroll") do
            SheetMiddle do
              render Shared::Menu.new
            end
          end
        end
      end
    end
  end

  def menu_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      fill: "none",
      viewbox: "0 0 24 24",
      stroke_width: "1.5",
      stroke: "currentColor",
      class: "w-4 h-4"
    ) do |s|
      s.path(
        stroke_linecap: "round",
        stroke_linejoin: "round",
        d: "M3.75 9h16.5m-16.5 6.75h16.5"
      )
    end
  end
end
