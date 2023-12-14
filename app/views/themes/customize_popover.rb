# frozen_string_literal: true

module Themes
  class CustomizePopover < ApplicationComponent
    def initialize(theme:)
      @theme = theme
    end

    def template
      render PhlexUI::Popover.new(options: { trigger: 'click', placement: 'bottom-end' }) do
        render PhlexUI::Popover::Trigger.new do
          render PhlexUI::Button.new(variant: :outline) { "Customize Theme" }
        end
        render PhlexUI::Popover::Content.new(class: 'w-96 p-6') do
          div(class: 'space-y-0') do
            render PhlexUI::Typography::Large.new { "Customize" }
            render PhlexUI::Typography::P.new(class: 'text-muted-foreground') { "Choose how your app looks" }
          end
          div(class: 'grid grid-cols-3 gap-2 mt-4') do
            Theme::CSS.all_themes.each do |name, color_hash|
              render_color_picker(name, color_hash, selected: name.to_s.downcase == @theme)
            end
          end
        end
      end
    end

    private

    def render_color_picker(name, color_hash, selected: false)
      render PhlexUI::Link.new(href: helpers.theme_path(name&.downcase), variant: :outline, class: tokens('!justify-start', -> { selected } => "ring-neutral-950 ring-1") ) do
        div(class: "w-4 h-4 rounded-full shrink-0 mr-2 ring-white dark:hidden", style: "background-color: hsl(#{color_hash[:root][:primary].split.join(',')})") do
        end
        div(class: "w-4 h-4 rounded-full shrink-0 mr-2 ring-white hidden dark:block", style: "background-color: hsl(#{color_hash[:dark][:primary].split.join(',')})") do
        end
        plain name&.capitalize
      end
    end
  end
end