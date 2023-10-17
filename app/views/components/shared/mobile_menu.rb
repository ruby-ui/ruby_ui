# frozen_string_literal: true

class Shared::MobileMenu < ApplicationComponent
    def initialize(**attributes)
        @attributes = attributes
    end

    def template
        render Sheet.new(class: @attributes[:class]) do
            render SheetTrigger.new do
                render Button.new(variant: :ghost, size: :icon) do
                    menu_icon
                end
            end
            render SheetContent.new(class: 'w-[300px]', side: :left) do
                div(class: 'flex flex-col h-full') do
                    render SheetHeader.new do
                        div(class: 'pl-2') do
                            render Shared::Logo.new
                        end
                    end
                    div(class: 'flex-grow overflow-y-scroll') do
                        render SheetMiddle.new do
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
