# frozen_string_literal: true

module Themes
  class CustomizePopover < ApplicationComponent
    def initialize(theme:)
      @theme = theme
    end

    def view_template
      render PhlexUI::Popover.new(options: {trigger: "click", placement: "bottom-end"}) do
        render PhlexUI::Popover::Trigger.new do
          render PhlexUI::Button.new(variant: :outline) do
            color_swatch_icon
            plain "Customize Theme"
          end
        end
        render PhlexUI::Popover::Content.new(class: "w-96 p-6") do
          div(class: "space-y-0") do
            render PhlexUI::Typography::Large.new { "Customize" }
            render PhlexUI::Typography::P.new(class: "text-muted-foreground") { "Choose how your app looks" }
          end
          div(class: "grid grid-cols-3 gap-2 mt-4") do
            Theme::CSS.all_themes.each do |name, color_hash|
              render_color_picker(name, color_hash, selected: name.to_s.downcase == @theme)
            end
          end
        end
      end
    end

    private

    def render_color_picker(name, color_hash, selected: false)
      render PhlexUI::Link.new(href: helpers.theme_path(name&.downcase), variant: :outline, class: tokens("!justify-start", -> { selected } => "ring-neutral-950 ring-1")) do
        div(class: "w-4 h-4 rounded-full shrink-0 mr-2 ring-white dark:hidden", style: "background-color: hsl(#{color_hash[:root][:primary].split.join(",")})") do
        end
        div(class: "w-4 h-4 rounded-full shrink-0 mr-2 ring-white hidden dark:block", style: "background-color: hsl(#{color_hash[:dark][:primary].split.join(",")})") do
        end
        plain name&.capitalize
      end
    end

    def color_swatch_icon
      svg(
        xmlns: "http://www.w3.org/2000/svg",
        fill: "currentColor",
        viewbox: "0 0 256 256",
        class: "w-5 h-5 shrink-0 mr-2 -ml-1"
      ) do |s|
        s.path(
          d:
            "M200.77,53.89A103.27,103.27,0,0,0,128,24h-1.07A104,104,0,0,0,24,128c0,43,26.58,79.06,69.36,94.17A32,32,0,0,0,136,192a16,16,0,0,1,16-16h46.21a31.81,31.81,0,0,0,31.2-24.88,104.43,104.43,0,0,0,2.59-24A103.28,103.28,0,0,0,200.77,53.89Zm13,93.71A15.89,15.89,0,0,1,198.21,160H152a32,32,0,0,0-32,32,16,16,0,0,1-21.31,15.07C62.49,194.3,40,164,40,128a88,88,0,0,1,87.09-88h.9a88.35,88.35,0,0,1,88,87.25A88.86,88.86,0,0,1,213.81,147.6ZM140,76a12,12,0,1,1-12-12A12,12,0,0,1,140,76ZM96,100A12,12,0,1,1,84,88,12,12,0,0,1,96,100Zm0,56a12,12,0,1,1-12-12A12,12,0,0,1,96,156Zm88-56a12,12,0,1,1-12-12A12,12,0,0,1,184,100Z"
        )
      end
    end
  end
end
